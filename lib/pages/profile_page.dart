import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../repository/firebase_api.dart';
import 'package:recetapp/pages/recipe_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final FirebaseApi _firebaseApi = FirebaseApi(); // Instancia de FirebaseApi

  String _backgroundImage = ""; // Imagen predeterminada para fondo
  String _profileImage = ""; // Imagen predeterminada para perfil
  String _userName = "Usuario";
  int _followers = 0, _views = 0, _recipes = 0; // Estadísticas

  late TabController _tabController;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Cambia a 2 pestañas
    _loadUserData();
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Cargar datos del usuario desde Firestore
  Future<void> _loadUserData() async {
    try {
      final userData = await _firebaseApi.getUserData();
      if (userData != null) {
        setState(() {
          _userName = userData["name"] ?? "Usuario";
          _profileImage = userData["profileImageUrl"] ?? ""; // Actualización aquí
          _backgroundImage = userData["backgroundImage"] ?? "";
          _followers = userData["followers"] ?? 0;
          _views = userData["views"] ?? 0;
          _recipes = userData["recipes"] ?? 0;
        });
      }
    } catch (e) {
      print("Error al cargar datos del usuario: $e");
    }
  }


  File? imageGobal;

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() => this.imageGobal = imageTemp);
      _firebaseApi.updateProfilePicture(imageGobal);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }

  }

  Future pickImageC() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);

      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() => this.imageGobal = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Imagen de fondo y configuración
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  // Implement background image change logic here, if needed
                },
                child: _backgroundImage.isNotEmpty
                    ? Image.network(
                  _backgroundImage,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                    : Container(
                  height: 200,
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.image, color: Colors.white, size: 50),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  onPressed: () {
                    print("Configuración presionada");
                  },
                  icon: const Icon(Icons.settings, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Imagen de perfil
          GestureDetector(
            onTap: pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: imageGobal != null ? FileImage(imageGobal!) : null,
              child: _profileImage.isEmpty
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: 10),

          // Nombre del usuario
          Text(
            _userName,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),

          const SizedBox(height: 10),

          // Estadísticas de seguidores, vistas, recetas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat("Seguidores", _followers),
              _buildStat("Vistas", _views),
              _buildStat("Recetas", _recipes),
            ],
          ),

          const SizedBox(height: 10),

          // Pestañas de Recetas, Favoritos, Guardados
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.grid_on), text: "Recetas"),
              Tab(icon: Icon(Icons.favorite), text: "Favoritos"),
            ],
          ),

          // Contenido de las pestañas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent("Aún no hay recetas."),
                _buildFavoritesTab(), // Ahora muestra los favoritos correctamente
              ],
            ),
          ),

        ],
      ),
    );
  }
  Widget _buildFavoritesTab() {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Aún no hay favoritos.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final favorites = snapshot.data!.docs;

        return ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final recipe = favorites[index].data() as Map<String, dynamic>;
            return buildRecipeCard(
              context: context,
              title: recipe['title'] ?? 'Sin título',
              imageUrl: recipe['image'] ?? 'https://via.placeholder.com/300',
              recipe: recipe,
              isFavoriteTab: true, // Indica que estás en la pestaña de favoritos
            );
          },
        );
      },
    );
  }


  Widget _buildStat(String label, int value) {
    return Column(
      children: [
        Text(
          "$value",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTabContent(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}

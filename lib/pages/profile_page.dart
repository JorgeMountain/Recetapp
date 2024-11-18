import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  String _backgroundImage = ""; // Imagen predeterminada para fondo
  String _profileImage = ""; // Imagen predeterminada para perfil
  String _userName = "Usuario";
  int _followers = 0, _views = 0, _recipes = 0; // Estadísticas

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _userName = userDoc.data()?["name"] ?? "Usuario";
          _profileImage = userDoc.data()?["profileImage"] ?? "";
          _backgroundImage = userDoc.data()?["backgroundImage"] ?? "";
          _followers = userDoc.data()?["followers"] ?? 0;
          _views = userDoc.data()?["views"] ?? 0;
          _recipes = userDoc.data()?["recipes"] ?? 0;
        });
      }
    } catch (e) {
      print("Error al cargar datos del usuario: $e");
    }
  }

  // Cambiar imagen (perfil o fondo)
  Future<void> _changeImage(String type) async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final file = File(image.path);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final folder = type == "profile" ? "profile_images" : "background_images";
      final ref = FirebaseStorage.instance.ref().child("$folder/${user.uid}/$fileName");

      // Subir archivo a Firebase Storage
      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      setState(() {
        if (type == "profile") {
          _profileImage = url;
        } else {
          _backgroundImage = url;
        }
      });

      // Actualizar Firestore
      final field = type == "profile" ? "profileImage" : "backgroundImage";
      await FirebaseFirestore.instance.collection("users").doc(user.uid).update({field: url});
    } catch (e) {
      print("Error al cambiar la imagen: $e");
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
                onTap: () => _changeImage("background"),
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
                    // Implementa configuración si es necesario
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
            onTap: () => _changeImage("profile"),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _profileImage.isNotEmpty ? NetworkImage(_profileImage) : null,
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
              Tab(icon: Icon(Icons.star), text: "Guardados"),
            ],
          ),

          // Contenido de las pestañas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent("Aún no hay recetas."),
                _buildTabContent("Aún no hay favoritos."),
                _buildTabContent("Aún no hay guardados."),
              ],
            ),
          ),
        ],
      ),
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

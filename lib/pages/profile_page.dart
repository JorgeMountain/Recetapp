import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recetapp/pages/recipe_detail_screen.dart';
import 'package:recetapp/repository/spoonacular_api.dart';
import '../repository/firebase_api.dart';
import 'settings_page.dart'; // Importa la página de configuración
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

      setState(() {
        imageGobal = imageTemp;
      });

      // Actualizar la imagen en Firebase
      final updatedUrl = await _firebaseApi.updateProfilePicture(imageGobal);
      setState(() {
        _profileImage = updatedUrl; // Actualizar la URL en el estado actual
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil actualizada')),
      );
    } on PlatformException catch (e) {
      print('Error al seleccionar la imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al seleccionar la imagen')),
      );
    } catch (e) {
      print('Error general: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar la foto de perfil')),
      );
    }
  }
  Future pickBackgroundImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image == null) return;

      final imageTemp = File(image.path);

      // Actualizar la imagen en Firebase
      final updatedUrl = await _firebaseApi.updateBackgroundImage(imageTemp);
      setState(() {
        _backgroundImage = updatedUrl; // Actualizar la URL en el estado actual
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen de fondo actualizada')),
      );
    } on PlatformException catch (e) {
      print('Error al seleccionar la imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al seleccionar la imagen')),
      );
    } catch (e) {
      print('Error general: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar la imagen de fondo')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Imagen de fondo
          Stack(
            children: [
              GestureDetector(
                onTap: pickBackgroundImage, // Función para seleccionar la imagen
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                    );
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
              backgroundImage: _profileImage.isNotEmpty
                  ? NetworkImage(_profileImage)
                  : (imageGobal != null ? FileImage(imageGobal!) : null),
              child: _profileImage.isEmpty && imageGobal == null
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
          ),

          const SizedBox(height: 10),

          // Nombre del usuario (sin botón de configuración)
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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

          // Pestañas de Recetas, Favoritos
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
                _buildUserRecipesTab(), // Pestaña de recetas del usuario
                _buildFavoritesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // Pestaña de Recetas del Usuario
  Widget _buildUserRecipesTab() {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('recipes') // Colección de recetas
          .where('userId', isEqualTo: userId) // Filtro por usuario actual
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No has publicado recetas aún.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final userRecipes = snapshot.data!.docs;

        return ListView.builder(
          itemCount: userRecipes.length,
          itemBuilder: (context, index) {
            final recipe = userRecipes[index].data() as Map<String, dynamic>;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailScreen(recipe: recipe),
                  ),
                );
              },
              child: buildRecipeCardusr(
                context: context,
                title: recipe['title'] ?? 'Sin título',
                imageUrl: recipe['image'] ?? 'https://via.placeholder.com/300',
                recipe: recipe,
                isFavoriteTab: false,
              ),
            );
          },
        );
      },
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
          print('No hay favoritos en Firebase');
          return const Center(
            child: Text(
              'Aún no hay favoritos.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final favorites = snapshot.data!.docs;
        print('Favoritos recuperados: ${favorites.length}');

        return ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final recipeData = favorites[index].data();
            print('Datos de receta en el índice $index: $recipeData');

            if (recipeData == null) {
              print('Receta nula en el índice $index');
              return const Center(
                child: Text(
                  'Error al cargar la receta.',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            final recipe = recipeData as Map<String, dynamic>;
            print('Receta procesada en el índice $index: $recipe');

            // Verifica si el ID está presente en los datos
            if (!recipe.containsKey('id') || recipe['id'] == null) {
              print('Receta inválida: falta el ID en el índice $index. Datos: $recipe');
              return const Center(
                child: Text(
                  'Receta inválida: falta el ID.',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            return GestureDetector(
              onTap: () async {
                try {
                  // ID de la receta
                  final int? recipeId = recipe['id'];
                  if (recipeId == null) {
                    print('Error: Receta inválida, falta el ID');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Receta inválida: falta el ID.')),
                    );
                    return;
                  }
                  print('Intentando cargar detalles para la receta con ID: $recipeId');

                  // Verifica si ya tiene detalles completos
                  if (recipe.containsKey('extendedIngredients') && recipe.containsKey('analyzedInstructions')) {
                    print('Detalles ya presentes: Navegando a pantalla de detalles');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  } else {
                    print('Detalles incompletos: Recuperando desde la API para ID $recipeId');
                    final recipeDetails = await SpoonacularApi().fetchRecipeDetails(recipeId);
                    print('Detalles cargados: $recipeDetails');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(recipe: recipeDetails),
                      ),
                    );
                  }
                } catch (e) {
                  print('Error al cargar detalles de la receta: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No se pudo cargar la receta.')),
                  );
                }
              },
              child: buildRecipeCard(
                context: context,
                title: recipe['title'] ?? 'Sin título',
                imageUrl: recipe['image'] ?? 'https://via.placeholder.com/300',
                recipe: recipe,
                isFavoriteTab: true,
              ),
            );
          },
        );
      },
    );
  }

  Widget buildRecipeCardusr({
    required BuildContext context,
    required String title,
    required String imageUrl,
    required Map<String, dynamic> recipe,
    required bool isFavoriteTab,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
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

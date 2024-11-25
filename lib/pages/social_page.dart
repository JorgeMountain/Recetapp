import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:recetapp/models/recipe.dart';
import 'package:recetapp/pages/recipe_detail_screen.dart';
import 'package:recetapp/repository/firebase_api.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({Key? key}) : super(key: key);

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _portionsController = TextEditingController();
  final _timeController = TextEditingController();

  List<String> ingredients = [''];
  List<String> steps = [''];
  File? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _createPost() async {
    if (_formKey.currentState!.validate() &&
        _selectedImage != null &&
        ingredients.isNotEmpty &&
        steps.isNotEmpty) {
      setState(() => _isUploading = true);

      final currentUser = FirebaseAuth.instance.currentUser;

      try {
        final newRecipe = Recipe(
          id: '', // Será generado automáticamente en Firestore
          title: _titleController.text,
          description: _descriptionController.text,
          ingredients: ingredients,
          steps: steps,
          portions: _portionsController.text,
          time: _timeController.text,
          imageUrl: '', // Será agregado después de subir la imagen
          userId: currentUser?.uid ?? 'Unknown', // Almacena el userId
        );

        final result = await FirebaseApi().createRecipe(newRecipe, _selectedImage!);
        if (result.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receta publicada con éxito')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al publicar receta: $e')),
        );
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _toggleFavorite(String recipeId, bool isCurrentlyFavorite) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return; // Verifica si hay usuario autenticado.

    final recipeRef = FirebaseFirestore.instance.collection('recipes').doc(recipeId);

    try {
      if (isCurrentlyFavorite) {
        // Eliminar de favoritos
        await recipeRef.update({
          'favoriteBy': FieldValue.arrayRemove([currentUser.uid]),
        });
      } else {
        // Agregar a favoritos
        await recipeRef.update({
          'favoriteBy': FieldValue.arrayUnion([currentUser.uid]),
        });
      }
    } catch (e) {
      print('Error al actualizar favoritos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar favoritos')),
      );
    }
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: const Color(0xFF1C1C1C),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(_titleController, 'Título de la receta'),
                        const SizedBox(height: 10),
                        _buildTextField(_descriptionController, 'Descripción'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(_portionsController, 'Porciones')),
                            const SizedBox(width: 10),
                            Expanded(child: _buildTextField(_timeController, 'Tiempo (min)')),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Ingredientes dinámicos
                        const Text(
                          'Ingredientes:',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        _buildDynamicList(
                          context: context,
                          items: ingredients,
                          placeholder: 'Nuevo ingrediente',
                          onAdd: () => setState(() => ingredients.add('')),
                          onRemove: (index) => setState(() => ingredients.removeAt(index)),
                          onChange: (index, value) => setState(() => ingredients[index] = value),
                        ),

                        // Pasos dinámicos
                        const SizedBox(height: 10),
                        const Text(
                          'Pasos:',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        _buildDynamicList(
                          context: context,
                          items: steps,
                          placeholder: 'Nuevo paso',
                          onAdd: () => setState(() => steps.add('')),
                          onRemove: (index) => setState(() => steps.removeAt(index)),
                          onChange: (index, value) => setState(() => steps[index] = value),
                        ),

                        // Imagen de la receta
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: _selectedImage == null
                                ? const Icon(Icons.add_a_photo, color: Colors.white)
                                : Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _createPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6E6FA),
                    ),
                    child: _isUploading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Publicar', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value!.isEmpty ? 'Por favor ingresa $label' : null,
    );
  }

  Widget _buildDynamicList({
    required BuildContext context,
    required List<String> items,
    required String placeholder,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    required Function(int, String) onChange,
  }) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => onChange(i, value),
                    decoration: InputDecoration(
                      hintText: placeholder,
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF2C2C2C),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onRemove(i),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: onAdd,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF181818)),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181818),
        title: const Text('Publicaciones Sociales'),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: _showCreatePostDialog,
            child: Card(
              color: const Color(0xFF1C1C1C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add, size: 50, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      'Agregar Receta',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('recipes') // Cambiado de 'posts' a 'recipes'
                  .orderBy('id') // Puedes ordenar por cualquier campo, como 'timestamp' si lo añades.
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay publicaciones aún.',
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  );
                }

                final recipes = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index].data() as Map<String, dynamic>;
                    return _buildPostCard(recipe, recipes[index].id);
                  },
                );
              },
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> recipe, String recipeId) {
    final currentUser = FirebaseAuth.instance.currentUser;

    final isFavorite = recipe['favoriteBy'] != null &&
        (recipe['favoriteBy'] as List).contains(currentUser?.uid);

    return Card(
      color: const Color(0xFF1C1C1C),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: recipe),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la receta
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                recipe['image'] ?? 'https://via.placeholder.com/300',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título de la receta
                  Text(
                    recipe['title'] ?? 'Sin título',
                    style: const TextStyle(
                      color: Color(0xFFE6E6FA), // Color lavanda
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Descripción de la receta
                  Text(
                    recipe['description'] ?? 'Sin descripción',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 10),

                  // Botones de "like" y agregar a favoritos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.favorite,
                              color: isFavorite ? Colors.red : Colors.white70,
                            ),
                            onPressed: () async {
                              await _toggleFavorite(recipeId, isFavorite);
                            },
                          ),
                          Text(
                            '${recipe['favoriteBy']?.length ?? 0}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



}

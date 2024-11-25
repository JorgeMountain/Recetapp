import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recetapp/pages/recipe_detail_screen.dart';
import 'dart:async';
import 'package:recetapp/pages/recipe_card.dart';

import 'package:recetapp/repository/spoonacular_api.dart';

class FoodHomePage extends StatefulWidget {
  const FoodHomePage({super.key});

  @override
  State<FoodHomePage> createState() => _FoodHomePageState();
}

class _FoodHomePageState extends State<FoodHomePage> {
  final SpoonacularApi apiService = SpoonacularApi();
  List<dynamic> recipes = [];
  bool isLoading = false;
  int offset = 0;
  String selectedCategory = "Recomendados"; // Categoría activa

  @override
  void initState() {
    super.initState();
    fetchRecipes(); // Cargar recetas iniciales
  }
  String mapCategoryToQuery(String category) {
    switch (category.toLowerCase()) {
      case 'desayuno':
        return 'breakfast';
      case 'almuerzo':
        return 'lunch';
      case 'cena':
        return 'dinner';
      case 'bebidas':
        return 'drinks';
      default:
        return ''; // Para "Recomendados" u otros valores
    }
  }

  Future<void> fetchRecipes() async {
    setState(() {
      isLoading = true;
      recipes = []; // Limpiar la lista antes de cargar nuevas recetas
    });

    try {
      final query = mapCategoryToQuery(selectedCategory); // Mapea la categoría seleccionada
      final newRecipes = await apiService.fetchRecipesByCategory(
        category: query, // Pasar la categoría como query
        offset: offset,
      );
      setState(() {
        recipes = newRecipes;
      });
    } catch (e) {
      print('Error al obtener recetas: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar recetas: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF181818),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Lógica para buscar recetas
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categorías horizontales
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip("Recomendados"),
                  _buildCategoryChip("Desayuno"),
                  _buildCategoryChip("Almuerzo"),
                  _buildCategoryChip("Cena"),
                  _buildCategoryChip("Bebidas"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Mostrar recetas o mensaje de "No hay recetas"
            Expanded(
              child: recipes.isEmpty
                  ? Center(
                child: Text(
                  'No hay recetas disponibles para esta categoría.',
                  style: TextStyle(color: Colors.white),
                ),
              )
                  : ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return _buildRecipeCard(
                    recipe['title'] ?? 'Sin título',
                    recipe['image'] ?? 'https://via.placeholder.com/300',
                    recipe,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para las tarjetas de recetas más grandes
  Widget _buildRecipeCard(String title, String imageUrl, Map<String, dynamic> recipe, {bool isFavoriteTab = false}) {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Card(
        color: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: InkWell(
          onTap: () async {
            try {
              // Navegar a la pantalla de detalles
              final recipeDetails = await apiService.fetchRecipeDetails(recipe['id']);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailScreen(recipe: recipeDetails),
                ),
              );
            } catch (e) {
              print('Error al cargar detalles de la receta: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error al cargar la receta.')),
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen de la receta
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15.0)),
                child: Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[800],
                      child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Título de la receta
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE6E6FA), // Color lavanda
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Botón de favoritos
                    StatefulBuilder(
                      builder: (context, setState) {
                        bool isLoading = false;
                        return IconButton(
                          icon: isLoading
                              ? const CircularProgressIndicator()
                              : Icon(
                            isFavoriteTab ? Icons.favorite : Icons.favorite_border,
                            color: Colors.redAccent,
                          ),
                          onPressed: () async {
                            if (isFavoriteTab) {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .collection('favorites')
                                  .doc(recipe['id'].toString())
                                  .delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Receta eliminada de favoritos.')),
                              );
                            } else {
                              try {
                                final int recipeId = recipe['id'];
                                final recipeDetails = await SpoonacularApi().fetchRecipeDetails(recipeId);
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userId)
                                    .collection('favorites')
                                    .doc(recipeId.toString())
                                    .set(recipeDetails);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Receta añadida a favoritos.')),
                                );
                              } catch (e) {
                                print('Error al guardar la receta como favorito: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('No se pudo añadir a favoritos.')),
                                );
                              }
                            }
                          },



                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }






  // Widget para los chips de categorías
  Widget _buildCategoryChip(String label) {
    final bool isSelected = label == selectedCategory;
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        selected: isSelected,
        selectedColor: const Color(0xFFE6E6FA), // Color lavanda
        backgroundColor: const Color(0xFF1C1C1C), // Fondo oscuro
        onSelected: (selected) {
          if (selected && label != selectedCategory) {
            setState(() {
              selectedCategory = label; // Actualizar categoría activa
              offset = 0; // Reiniciar el offset
            });
            fetchRecipes(); // Cargar recetas para la nueva categoría
          }
        },
      ),
    );
  }
}

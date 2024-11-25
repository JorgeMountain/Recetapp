import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recetapp/pages/recipe_detail_screen.dart';
import 'package:recetapp/repository/spoonacular_api.dart';


Widget buildRecipeCard({
  required BuildContext context,
  required String title,
  required String imageUrl,
  required Map<String, dynamic> recipe,
  required bool isFavoriteTab,
}) {
  if (recipe.isEmpty) {
    print('buildRecipeCard: Receta vacía');
    return const Center(
      child: Text(
        'Receta inválida.',
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  if (!recipe.containsKey('id') || recipe['id'] == null) {
    print('buildRecipeCard: Receta inválida, falta el ID');
    return const Center(
      child: Text(
        'Receta inválida: falta el ID.',
        style: TextStyle(color: Colors.red),
      ),
    );
  }

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
            // Verificar si faltan los datos importantes
            if (!recipe.containsKey('extendedIngredients') || !recipe.containsKey('analyzedInstructions')) {
              final int recipeId = recipe['id'];
              print('buildRecipeCard: Faltan datos de la receta, recuperando detalles para ID: $recipeId');
              final detailedRecipe = await SpoonacularApi().fetchRecipeDetails(recipeId);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailScreen(recipe: detailedRecipe),
                ),
              );
            } else {
              // Si ya contiene todos los detalles, navega directamente
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailScreen(recipe: recipe),
                ),
              );
            }
          } catch (e) {
            print('Error al cargar detalles de la receta: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se pudo cargar los detalles de la receta.')),
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
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE6E6FA),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavoriteTab ? Icons.favorite : Icons.favorite_border,
                      color: Colors.redAccent,
                    ),
                    onPressed: () async {
                      final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                      final recipeId = recipe['id'].toString();

                      try {
                        if (isFavoriteTab) {
                          // Si estamos en la pestaña de favoritos, eliminamos la receta
                          print('Eliminando la receta de favoritos con ID: $recipeId');
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .collection('favorites')
                              .doc(recipeId)
                              .delete();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Receta eliminada de favoritos.')),
                          );
                        } else {
                          // Si no estamos en la pestaña de favoritos, agregamos la receta
                          print('Agregando la receta a favoritos con ID: $recipeId');
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .collection('favorites')
                              .doc(recipeId)
                              .set(recipe);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Receta añadida a favoritos.')),
                          );
                        }
                      } catch (e) {
                        print('Error al actualizar favoritos: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al actualizar favoritos: $e')),
                        );
                      }
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

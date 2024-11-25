import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recetapp/pages/recipe_detail_screen.dart';


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
        onTap: () {
          print('buildRecipeCard: Datos de la receta: $recipe');

          // Validación del campo 'id' en la receta
          if (!recipe.containsKey('id') || recipe['id'] == null) {
            print('Error: La receta no tiene un ID válido');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Receta inválida: falta el ID.')),
            );
            return;
          }

          print('buildRecipeCard: Se presionó la receta con ID: ${recipe['id']}');

          // Navegación a los detalles de la receta
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
                    onPressed: () {
                      print('buildRecipeCard: Presionaste favorito para la receta con ID: ${recipe['id']}');
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

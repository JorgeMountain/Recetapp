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
            final recipeDetails = await FirebaseFirestore.instance
                .collection('recipes')
                .doc(recipe['id'].toString())
                .get();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailScreen(recipe: recipeDetails.data() as Map<String, dynamic>),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error al cargar la receta.')),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .collection('favorites')
                            .doc(recipe['id'].toString())
                            .set(recipe);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Receta añadida a favoritos.')),
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

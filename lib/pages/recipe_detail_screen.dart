import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;

  RecipeDetailScreen({required this.recipe});

  @override
  Widget build(BuildContext context) {
    // Verificar si los datos son de Firestore
    final isFirestoreRecipe = recipe.containsKey('ingredients') && recipe.containsKey('steps');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          recipe['title'] ?? 'Detalles de la receta',
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: const Color(0xFF181818),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la receta
            recipe['image'] != null
                ? ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
              child: Image.network(
                recipe['image'],
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            )
                : Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
              child: Icon(Icons.fastfood, size: 100, color: Colors.grey[500]),
            ),

            // Información principal
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['title'] ?? 'Sin título',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Verificar si el tiempo de preparación existe en ambos casos
                      if (isFirestoreRecipe && recipe['time'] != null)
                        Row(
                          children: [
                            const Icon(Icons.timer, color: Colors.green),
                            const SizedBox(width: 5),
                            Text(
                              '${recipe['time']} min',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        )
                      else if (!isFirestoreRecipe && recipe['readyInMinutes'] != null)
                        Row(
                          children: [
                            const Icon(Icons.timer, color: Colors.green),
                            const SizedBox(width: 5),
                            Text(
                              '${recipe['readyInMinutes']} min',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      const SizedBox(width: 20),
                      // Verificar si las porciones existen en ambos casos
                      if (isFirestoreRecipe && recipe['portions'] != null)
                        Row(
                          children: [
                            const Icon(Icons.people, color: Colors.blue),
                            const SizedBox(width: 5),
                            Text(
                              '${recipe['portions']} porciones',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        )
                      else if (!isFirestoreRecipe && recipe['servings'] != null)
                        Row(
                          children: [
                            const Icon(Icons.people, color: Colors.blue),
                            const SizedBox(width: 5),
                            Text(
                              '${recipe['servings']} porciones',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Verificar la descripción para ambos casos
                  Text(
                    recipe['description'] ??
                        (recipe['summary']?.replaceAll(RegExp(r'<[^>]*>'), '') ?? 'No se encontró descripción.'),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Ingredientes
            if (isFirestoreRecipe && recipe['ingredients'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Ingredientes',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(recipe['ingredients'].length, (index) {
                      final ingredient = recipe['ingredients'][index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Text(
                          '- $ingredient',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }),
                  ],
                ),
              )
            else if (!isFirestoreRecipe &&
                recipe['extendedIngredients'] != null &&
                recipe['extendedIngredients'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Ingredientes',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(recipe['extendedIngredients'].length, (index) {
                      final ingredient = recipe['extendedIngredients'][index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Text(
                          '- ${ingredient['original']}',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const Text(
                  'Ingredientes no disponibles.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),

            // Pasos de preparación
            if (isFirestoreRecipe && recipe['steps'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Preparación',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(recipe['steps'].length, (index) {
                      final step = recipe['steps'][index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                step,
                                style: const TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              )
            else if (!isFirestoreRecipe &&
                recipe['analyzedInstructions'] != null &&
                recipe['analyzedInstructions'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Preparación',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(recipe['analyzedInstructions'][0]['steps'].length, (index) {
                      final step = recipe['analyzedInstructions'][0]['steps'][index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                step['step'],
                                style: const TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const Text(
                  'Pasos de preparación no disponibles.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF1C1C1C),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recetapp/pages/recipes_result_page.dart'; // Asegúrate de importar tu página de resultados.

class IngredientsListPage extends StatefulWidget {
  const IngredientsListPage({Key? key}) : super(key: key);

  @override
  State<IngredientsListPage> createState() => _IngredientsListPageState();
}

class _IngredientsListPageState extends State<IngredientsListPage> {
  final TextEditingController _ingredientController = TextEditingController();
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _addIngredient(String ingredient) async {
    if (ingredient.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('ingredients')
          .add({'name': ingredient});
      _ingredientController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrediente agregado.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar ingrediente: $e')),
      );
    }
  }

  Future<void> _deleteIngredient(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('ingredients')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrediente eliminado.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar ingrediente: $e')),
      );
    }
  }

  void _searchRecipes() async {
    final ingredientsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('ingredients')
        .get();

    final ingredients = ingredientsSnapshot.docs
        .map((doc) => doc['name'] as String)
        .toList();

    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes ingredientes para buscar.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipesResultPage(ingredients: ingredients),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Ingredientes'),
        backgroundColor: const Color(0xFF181818),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input para agregar ingredientes
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingredientController,
                    decoration: InputDecoration(
                      hintText: 'Agregar ingrediente',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF2C2C2C),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _addIngredient(_ingredientController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF181818),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  child: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Lista de ingredientes
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('ingredients')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay ingredientes en tu despensa.',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final ingredients = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = ingredients[index];
                      return Card(
                        color: const Color(0xFF2C2C2C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            ingredient['name'],
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteIngredient(ingredient.id);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Botón para buscar recetas
            ElevatedButton(
              onPressed: _searchRecipes,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF181818),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              child: const Text(
                'Buscar recetas',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF1C1C1C),
    );
  }
}

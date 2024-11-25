import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recetapp/repository/spoonacular_api.dart';
import 'package:recetapp/pages/recipe_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recetapp/pages/recipe_card.dart';

class RecipesResultPage extends StatefulWidget {
  final List<String> ingredients;

  const RecipesResultPage({Key? key, required this.ingredients})
      : super(key: key);

  @override
  State<RecipesResultPage> createState() => _RecipesResultPageState();
}

class _RecipesResultPageState extends State<RecipesResultPage> {
  final SpoonacularApi apiService = SpoonacularApi();
  List<dynamic> recipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipesByIngredients();
  }

  Future<void> fetchRecipesByIngredients() async {
    try {
      final ingredientQuery = widget.ingredients.join(','); // Combina ingredientes en una cadena separada por comas
      final fetchedRecipes = await apiService.fetchRecipesByIngredients(ingredientQuery);

      setState(() {
        recipes = fetchedRecipes;
        isLoading = false;
      });
    } catch (e) {
      print('Error al obtener recetas: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar recetas: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados de la búsqueda'),
        backgroundColor: const Color(0xFF181818),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recipes.isEmpty
          ? const Center(
        child: Text(
          'No se encontraron recetas con estos ingredientes.',
          style: TextStyle(color: Colors.white),
        ),
      )
          : ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return buildRecipeCard(
            context: context,
            title: recipe['title'] ?? 'Sin título',
            imageUrl: recipe['image'] ?? 'https://via.placeholder.com/300',
            recipe: recipe,
            isFavoriteTab: false, // No estamos en la pestaña de favoritos
          );
        },
      ),
      backgroundColor: const Color(0xFF1C1C1C),
    );
  }
}

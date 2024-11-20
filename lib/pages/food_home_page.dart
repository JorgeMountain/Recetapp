import 'package:flutter/material.dart';
import 'package:recetapp/pages/recipe_detail_screen.dart';
import 'dart:async';

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
  Widget _buildRecipeCard(String title, String imageUrl, Map<String, dynamic> recipe) {
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
              // Verifica si el ID de la receta está presente
              if (recipe['id'] == null) {
                throw Exception('El ID de la receta no está disponible.');
              }

              // Llama al método fetchRecipeDetails con el ID de la receta
              final recipeDetails = await apiService.fetchRecipeDetails(recipe['id']);

              // Verifica si los detalles contienen los campos esperados
              if (recipeDetails['extendedIngredients'] == null ||
                  recipeDetails['analyzedInstructions'] == null) {
                throw Exception('Información incompleta de la receta.');
              }

              // Navega a la pantalla de detalles con la información completa
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailScreen(recipe: recipeDetails),
                ),
              );
            } catch (e) {
              print('Error al obtener detalles de la receta: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('No se pudo cargar la receta: ${e.toString()}')),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título de la receta
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE6E6FA), // Color lavanda
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
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

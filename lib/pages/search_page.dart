import 'package:flutter/material.dart';
import 'package:recetapp/repository/spoonacular_api.dart';
import 'package:recetapp/pages/recipe_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final SpoonacularApi apiService = SpoonacularApi();

  // Variables para búsqueda
  List<dynamic> recipes = [];
  bool isLoading = false;
  bool isAdvancedSearchVisible = false;

  // Variables para filtros avanzados
  String selectedType = '';
  String selectedCuisine = '';
  String selectedDiet = '';
  int? maxReadyTime;

  // Opciones para filtros avanzados
  final List<String> types = ['main course', 'side dish', 'dessert', 'appetizer', 'salad', 'breakfast'];
  final List<String> cuisines = ['Mexican', 'Italian', 'Chinese', 'American', 'French', 'Indian'];
  final List<String> diets = ['vegan', 'vegetarian', 'ketogenic', 'gluten free', 'paleo', 'low carb'];

  Future<void> _searchRecipes() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<dynamic> fetchedRecipes = [];
      final query = _searchController.text.trim();

      if (query.isNotEmpty) {
        // Si el usuario escribe algo en la barra de búsqueda
        fetchedRecipes = await apiService.fetchRecipesBySearch(
          query: query,
          tags: [], // Lista vacía de etiquetas cuando no se usan
        );
      } else {
        // Si no hay texto en la barra, utiliza los filtros avanzados
        fetchedRecipes = await apiService.fetchRecipesByAdvancedSearch(
          type: selectedType,
          cuisine: selectedCuisine,
          diet: selectedDiet,
          maxReadyTime: maxReadyTime,
        );
      }

      setState(() {
        recipes = fetchedRecipes;
        isLoading = false;
      });
    } catch (e) {
      print('Error en la búsqueda: $e');
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al buscar recetas: $e')),
      );
    }
  }


  void _resetAdvancedFilters() {
    setState(() {
      selectedType = '';
      selectedCuisine = '';
      selectedDiet = '';
      maxReadyTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Recetas'),
        backgroundColor: const Color(0xFF181818),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barra de búsqueda normal
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar recetas por nombre...',
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
                  onPressed: _searchRecipes,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF181818),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  child: const Text('Buscar'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Botón para mostrar/ocultar búsqueda avanzada
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isAdvancedSearchVisible = !isAdvancedSearchVisible;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF181818),
              ),
              child: Text(isAdvancedSearchVisible ? 'Ocultar Búsqueda Avanzada' : 'Mostrar Búsqueda Avanzada'),
            ),
            const SizedBox(height: 10),

            // Opciones avanzadas
            if (isAdvancedSearchVisible)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedType.isEmpty ? null : selectedType,
                    items: types
                        .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Comida',
                      filled: true,
                      fillColor: Color(0xFF2C2C2C),
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedType = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCuisine.isEmpty ? null : selectedCuisine,
                    items: cuisines
                        .map((cuisine) => DropdownMenuItem(
                      value: cuisine,
                      child: Text(cuisine),
                    ))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Cocina',
                      filled: true,
                      fillColor: Color(0xFF2C2C2C),
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedCuisine = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedDiet.isEmpty ? null : selectedDiet,
                    items: diets
                        .map((diet) => DropdownMenuItem(
                      value: diet,
                      child: Text(diet),
                    ))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Dieta',
                      filled: true,
                      fillColor: Color(0xFF2C2C2C),
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedDiet = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tiempo máximo de preparación (min)',
                      filled: true,
                      fillColor: Color(0xFF2C2C2C),
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      setState(() {
                        maxReadyTime = int.tryParse(value);
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _resetAdvancedFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:const Color(0xFF181818),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    child: const Text('Restablecer Filtros'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _searchRecipes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF181818),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    child: const Text('Buscar con Filtros'),
                  ),
                ],
              ),
            const SizedBox(height: 20),

            // Resultados de la búsqueda
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : recipes.isEmpty
                  ? const Center(
                child: Text(
                  'No se encontraron recetas.',
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
                    isFavoriteTab: false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF1C1C1C),
    );
  }
}

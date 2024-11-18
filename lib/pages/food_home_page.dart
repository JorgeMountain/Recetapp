import 'package:flutter/material.dart';

class FoodHomePage extends StatefulWidget {
  const FoodHomePage({super.key});

  @override
  State<FoodHomePage> createState() => _FoodHomePageState();
}

class _FoodHomePageState extends State<FoodHomePage> {
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
                  _buildCategoryChip("Recomendados", true),
                  _buildCategoryChip("Tendencias", false),
                  _buildCategoryChip("Desayuno", false),
                  _buildCategoryChip("Almuerzo", false),
                  _buildCategoryChip("Cena", false),
                  _buildCategoryChip("Bebidas", false),
                  _buildCategoryChip("Mascotas", false),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Lista de tarjetas de recetas más grandes
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Número de recetas de ejemplo
                itemBuilder: (context, index) {
                  return _buildRecipeCard(
                    "Receta $index",
                    "https://via.placeholder.com/300", // Imagen de muestra
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
  Widget _buildRecipeCard(String title, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Card(
        color: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
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
                  IconButton(
                    icon: const Icon(Icons.bookmark_border, color: Colors.white),
                    onPressed: () {
                      // Lógica para guardar recetas
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para los chips de categorías
  Widget _buildCategoryChip(String label, bool isSelected) {
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
          // Cambiar la categoría activa
        },
      ),
    );
  }
}

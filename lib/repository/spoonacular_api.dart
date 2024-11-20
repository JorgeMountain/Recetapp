import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiKey = '2af2f746ae914fa785c33a5929475e57';
const String baseUrl = 'https://api.spoonacular.com/recipes';

class SpoonacularApi {
  Future<List<dynamic>> fetchRecipes({int offset = 0}) async {
    final response = await http.get(Uri.parse('$baseUrl/random?apiKey=$apiKey&number=10&offset=$offset'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['recipes'];
    } else {
      throw Exception('Failed to load recipes');
    }
  }
  Future<List<dynamic>> fetchRecipesByCategory({required String category, int offset = 0}) async {
    // Construcción del endpoint dependiendo de la categoría
    final endpoint = category.isEmpty
        ? '$baseUrl/random?apiKey=$apiKey&number=10&offset=$offset'
        : '$baseUrl/complexSearch?apiKey=$apiKey&query=$category&addRecipeInformation=true&number=10&offset=$offset';

    try {
      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return category.isEmpty ? jsonData['recipes'] : jsonData['results'];
      } else {
        print('Error en la API: ${response.body}');
        throw Exception('No se pudieron cargar las recetas para la categoría: $category');
      }
    } catch (e) {
      print('Error en fetchRecipesByCategory: $e');
      throw Exception('Error al obtener recetas: $e');
    }
  }

  Future<Map<String, dynamic>> fetchRecipeDetails(int recipeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$recipeId/information?apiKey=$apiKey'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Error al cargar detalles: ${response.body}');
      throw Exception('No se pudo obtener información de la receta');
    }
  }


}

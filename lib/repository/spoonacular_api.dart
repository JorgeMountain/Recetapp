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
    try {
      print('fetchRecipeDetails: Cargando detalles para la receta con ID: $recipeId');
      final response = await http.get(
        Uri.parse('$baseUrl/$recipeId/information?apiKey=$apiKey'),
      );

      if (response.statusCode == 200) {
        final details = json.decode(response.body);
        print('fetchRecipeDetails: Detalles cargados correctamente: $details');
        return details;
      } else {
        print('fetchRecipeDetails: Error en la respuesta de la API: ${response.body}');
        throw Exception('No se pudo obtener información de la receta');
      }
    } catch (e) {
      print('fetchRecipeDetails: Error al cargar detalles: $e');
      throw Exception('Error al obtener detalles de la receta');
    }
  }

  Future<List<dynamic>> fetchRecipesByIngredients(String ingredients) async {
    final url = '$baseUrl/findByIngredients?apiKey=$apiKey&ingredients=$ingredients&number=10';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Error en la API: ${response.body}');
      throw Exception('No se pudieron cargar las recetas con los ingredientes proporcionados.');
    }
  }

  Future<List<dynamic>> fetchRecipesBySearch({required String query, required List<String> tags}) async {
    final tagQuery = tags.join(',');
    final response = await http.get(Uri.parse('$baseUrl/complexSearch?apiKey=$apiKey&query=$query&tags=$tagQuery&addRecipeInformation=true'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Error al buscar recetas');
    }
  }
  Future<List<dynamic>> fetchRecipesByAdvancedSearch({
    String type = '',
    String cuisine = '',
    String diet = '',
    int? maxReadyTime,
  }) async {
    // Construir los parámetros manualmente
    String url = '$baseUrl/complexSearch?apiKey=$apiKey&addRecipeInformation=true';

    if (type.isNotEmpty) {
      url += '&type=$type';
    }
    if (cuisine.isNotEmpty) {
      url += '&cuisine=$cuisine';
    }
    if (diet.isNotEmpty) {
      url += '&diet=$diet';
    }
    if (maxReadyTime != null) {
      url += '&maxReadyTime=$maxReadyTime';
    }

    // Imprimir para depuración
    print('fetchRecipesByAdvancedSearch: URL generada: $url');

    // Realizar la solicitud
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      print('fetchRecipesByAdvancedSearch: Error en la respuesta de la API: ${response.body}');
      throw Exception('Error al buscar recetas avanzadas');
    }
  }

}

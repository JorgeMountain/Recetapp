import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  final String apiKey = 'AIzaSyD7-LZ158LuZQ1Ls2qyMHVHOqT5XcX8anw'; // Reemplaza con tu clave API

  Future<String> translateText(String text, String targetLanguage) async {
    final String url = 'https://translation.googleapis.com/language/translate/v2';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'q': text,
        'target': targetLanguage,
        'key': apiKey,
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded['data']['translations'][0]['translatedText'];
    } else {
      throw Exception('Error al traducir texto: ${response.body}');
    }
  }
}

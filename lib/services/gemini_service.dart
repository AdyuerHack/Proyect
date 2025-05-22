import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart'; // <--- NUEVA LÍNEA: Importa el paquete logger

var logger = Logger(); // <--- NUEVA LÍNEA: Inicializa una instancia de Logger

class GeminiService {
  final String _apiKey;

  GeminiService({required String apiKey}) : _apiKey = apiKey;

  Future<String> generarRespuesta(String prompt) async {
    const endpoint = 'https://generativelanguage.googleapis.com/v1beta3/models/gemini-pro:generateContent';

    final body = {
      "contents": [
        {
          "parts": [
            {
              "text": prompt,
            }
          ]
        }
      ]
    };

    try {
      final response = await http
          .post(
        Uri.parse('$endpoint?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        logger.e('Error de la API: ${response.statusCode} - ${response.body}'); // <--- CAMBIO AQUÍ
        throw Exception('Error en la API de Gemini: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error al llamar a la API de Gemini: $e'); // <--- CAMBIO AQUÍ
      throw Exception('Error al llamar a la API de Gemini: $e');
    }
  }
}
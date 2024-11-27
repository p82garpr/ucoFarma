import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String _baseUrl = 'http://10.0.2.2:1234/v1/chat/completions'; // URL de LMStudio

  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "messages": [
            {
              "role": "system",
              "content": "Eres un asistente médico experto en medicamentos. Proporciona información precisa y útil sobre medicamentos, sus usos, efectos secundarios y precauciones. No des consejos médicos directos, solo información general."
            },
            {
              "role": "user",
              "content": message
            }
          ],
          "temperature": 0.7,
          "max_tokens": 800,
          "stream": false
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Error en la respuesta del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al comunicarse con el chatbot: $e');
    }
  }
}
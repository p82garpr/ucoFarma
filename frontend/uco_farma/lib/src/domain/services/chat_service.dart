import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medicine_model.dart';

class ChatService {
  final String _baseUrl = 'http://10.0.2.2:1234/v1/chat/completions'; // URL de LMStudio
  // ignore: prefer_final_fields
  List<Map<String, String>> _messageHistory = [];

  Future<String> sendMessage(String message, List<Medicine>? medicines) async {
    try {
      String medicinesContext = '';
      if (medicines != null && medicines.isNotEmpty) {
        medicinesContext = 'Los medicamentos actuales del usuario son:\n';
        for (var medicine in medicines) {
          String doseInfo = '';
          if (medicine.doses?.isNotEmpty ?? false) {
            final dose = medicine.doses!.first;
            doseInfo = '''
           Frecuencia: ${dose.frequency} veces al día
           Cantidad por dosis: ${dose.quantity}''';
                    }

          medicinesContext += '''- ${medicine.name} (CN: ${medicine.cn})
             Cantidad: ${medicine.quantity} dosis
             Tipo: ${medicine.type}
             $doseInfo\n''';
        }
      }

      //print('Contexto de medicamentos: $medicinesContext');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "messages": [
            {
              "role": "system",
              "content": """Eres un asistente médico experto en medicamentos. 
              Tu función es ayudar con información sobre los medicamentos del usuario y ayudarlo con sus sintomas sabiendo que tiene los
              siguientes medicamentos asi como las dosis que debe tomar de cada uno:
              
              $medicinesContext
              
              Tu funcion es responder las preguntas medicas que el usuario haga, proporcionando informaciono precisa, util y concisa
              teniendo en cuenta cuando sea necesario la informacion relacionada con los medicamentos que el usuario tiene en el inventario.
              
              Debes de estar preparado para respondner preguntas sobre sintomas y dolencias en general, y si es necesario, recomendarle 
              algun medicamento de los que tenga.
              
              Tambien debes de estar preparado para responder a preguntas sobre como tomar los medicamentos, y si es necesario, sobre posibles
              efectos secundarios y precauciones que debe tener en cuenta a la hora de tomar los medicamentos.
              
              Si el paciente tiene alguna dolencia o problema, intenta recomendarle algun medicamento de los que tenga,
              y si no lo tiene, recomienda que compre otro, intenta siempre dar consejos medicos, pero a su vez
              recomienda la asistencia o hablar con un médico especialista.


              Recuerda siempre buscar responder la pregunta del usuario y no dar informacion irrelevante creando mensajes demasiado largos, 
              ademas, evita escribir el texto completamente plano, no markdown, es decir, sin el uso de negrita ni cursiva, intenta usar el formato adecuado para que el texto sea mas claro y facil de leer.
              """
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

  Future<String> sendMessagess(String message) async {
    try {
      // Agregar el mensaje del usuario al historial
      _messageHistory.add({
        "role": "user",
        "content": message,
      });

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "messages": _messageHistory,
          "temperature": 0.7,
          "max_tokens": 8000,
          "stream": false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botMessage = data['choices'][0]['message']['content'];

        // Agregar la respuesta del bot al historial
        _messageHistory.add({
          "role": "assistant",
          "content": botMessage,
        });

        return botMessage;
      } else {
        throw Exception('Error en la respuesta del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al comunicarse con el chatbot: $e');
    }
  }
}
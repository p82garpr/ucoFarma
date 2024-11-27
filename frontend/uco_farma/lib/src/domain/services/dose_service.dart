
import 'dart:convert';
import 'package:http/http.dart' as http;

class DoseService {
  final String _baseUrl = 'http://10.0.2.2:8000';

  Future<Map<String, dynamic>> takeDose(String userId, String cn, int quantity, String token) async {
    try {
      final queryParameters = {'cn': cn, 'quantity': quantity.toString()};
      
      final response = await http.put(
        Uri.parse('$_baseUrl/medicines/$userId/take-medicine').replace(queryParameters: queryParameters),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['detail'] ?? 'Error al tomar la dosis',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String,dynamic>> updateDose(String userId, String cn, int frecuency, int quantity, String token) async {
    try {
      final queryParameters = {'cn': cn, 'quantity': quantity.toString()};
      final response = await http.put(
        Uri.parse('$_baseUrl/doses/$userId/$cn').replace(queryParameters: queryParameters),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Error al actualizar la dosis',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }

  }


}
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'http://192.168.1.141:8000';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': email,    // Cambiado de 'correo' a 'username'
          'password': password, // Cambiado de 'contrasena' a 'password'
        },
      );

      //print('Status Code: ${response.statusCode}'); // Para depuración
      //print('Response body: ${response.body}'); // Para depuración

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Credenciales inválidas',
        };
      }
    } catch (e) {
      //print('Error: $e'); // Para depuración
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
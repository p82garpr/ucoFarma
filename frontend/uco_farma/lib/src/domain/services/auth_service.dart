import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:8000';

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': email, // Cambiado de 'correo' a 'username'
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

  Future<Map<String, dynamic>> register(
      String fullName, String email, String password, String birthdate) async {
    try {
      /*print('Enviando datos: ${json.encode({
        'fullname': fullName,
        'email': email,
        'password': password,
        'birthdate': birthdate,
      })}'); // Para depuración*/

      final response = await http.post(
        Uri.parse('$_baseUrl/users/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'fullname': fullName,
          'email': email,
          'password': password,
          'birthdate': birthdate,
        }),
      );

      //print('Status Code: ${response.statusCode}'); // Para depuración
      //print('Response body: ${response.body}'); // Para depuración

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'El servidor no devolvió ninguna respuesta',
        };
      }

      try {
        final responseData = json.decode(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          return {
            'success': true,
            'data': responseData,
          };
        } else {
          return {
            'success': false,
            'message': responseData['detail'] ?? 'Error al registrar usuario',
          };
        }
      } catch (e) {
        return {
          'success': false,
          'message':
              'Error al procesar la respuesta del servidor: ${e.toString()}',
        };
      }
    } catch (e) {
      //print('Error en registro: $e'); // Para depuración
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/me'),
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
        return {
          'success': false,
          'message': 'Error al obtener datos del usuario',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> changePassword(String newPassword, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'new_password': newPassword,
        }),
      );

      final decodedResponse = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': decodedResponse['message'],
        };
      } else {
        return {
          'success': false,
          'message': decodedResponse['detail'] ?? 'Error al actualizar la contraseña',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }
  
  Future<Map<String, dynamic>> addShoplist(
      String userId, String cn, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/shoplist/$userId/add-shoplist'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'cn': cn}),
      );
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Error al agregar medicamento a la lista de compras',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> deleteShoplist(
      String userId, String cn, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/shoplist/$userId/delete-shoplist'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'cn': cn}),
      );
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Error al eliminar medicamento de la lista de compras',
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

import 'dart:convert';
import 'package:http/http.dart' as http;

class ShoplistService {
  final String _baseUrl = 'https://ucofarma.onrender.com';

  Future<Map<String, dynamic>> addToShoplist(String userId, String cn, String token) async {
    try {
      final queryParameters = {'cn': cn};
      
      final response = await http.put(
        Uri.parse('$_baseUrl/shoplist/$userId/add-shoplist').replace(queryParameters: queryParameters),
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
          'message': error['detail'] ?? 'Error al añadir a la lista de compras',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> deleteFromShoplist(String userId, String cn, String token) async {
    try {
      final queryParameters = {'cn': cn};
      
      final response = await http.delete(
        Uri.parse('$_baseUrl/shoplist/$userId/delete-shoplist').replace(queryParameters: queryParameters),
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
          'message': error['detail'] ?? 'Error al eliminar de la lista de compras',
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
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medicine_model.dart';
//import '../models/cima_medicine_model.dart';

class MedicineService {
  final String _baseUrl = 'http://10.0.2.2:8000';
  final String _cimaApiUrl = 'https://cima.aemps.es/cima/rest';
  // EJEMPLO CONSULTA DE UN MEDICAMENTO : https://cima.aemps.es/cima/rest/medicamento?cn=741512

  Future<Map<String, dynamic>> addMedicine(
      String userId,
      String cn,
      String token,
      int quantity,
      String type,
      int frequency,
      double doseQuantity,
      bool wished,
      String startDate,
      String endDate) async {
    try {
      final cimaResponse =
          await http.get(Uri.parse('$_cimaApiUrl/medicamento?cn=$cn'));

      if (cimaResponse.statusCode == 200) {
        final cimaData = json.decode(cimaResponse.body);

        final medicine = Medicine(
          cn: cn,
          name: cimaData['nombre'] ?? '',
          quantity: quantity,
          type: type,
          doses: [
            Dose(
                frequency: frequency,
                quantity: doseQuantity.toInt(),
                startDate: startDate,
                endDate: endDate)
          ],
          wished: false,
        );

        final response = await http.post(
          Uri.parse('$_baseUrl/medicines/$userId/add-medicine'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(medicine.toJson()),
        );
        if (response.statusCode == 200) {
          return {
            'success': true,
            'data': json.decode(response.body),
          };
        } else {
          return {
            'success': false,
            'message': 'Error al añadir el medicamento',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Medicamento no encontrado en CIMA',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getMedicineCimaInfo(String cn) async {
    try {
      final response = await http.get(
        Uri.parse('$_cimaApiUrl/medicamento?cn=$cn'),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado al conectar con CIMA');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data.isNotEmpty) {
          return {
            'success': true,
            'data': data,
          };
        } else {
          return {
            'success': false,
            'message': 'No se encontró información para este medicamento',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Medicamento no encontrado en CIMA',
        };
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        return {
          'success': false,
          'message':
              'Error de conexión con CIMA. Compruebe su conexión a Internet.',
        };
      }
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> deleteMedicine(
      String userId, String cn, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/medicines/$userId/delete-medicine/$cn'),
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
          'message': 'Error al eliminar el medicamento',
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

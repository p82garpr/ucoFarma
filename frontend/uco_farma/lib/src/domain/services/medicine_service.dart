import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medicine_model.dart';

class MedicineService {
  final String _baseUrl = 'http://192.168.1.141:8000';
  final String _cimaApiUrl = 'https://cima.aemps.es/cima/rest';
  // EJEMPLO CONSULTA DE UN MEDICAMENTO : https://cima.aemps.es/cima/rest/medicamento?cn=741512


  Future<Map<String, dynamic>> addMedicine(String userId, String cn, String token, int quantity, String type, int frequency, int doseQuantity) async {
    try {
      final cimaResponse = await http.get(Uri.parse('$_cimaApiUrl/medicamento?cn=$cn'));
      
      if (cimaResponse.statusCode == 200) {
        final cimaData = json.decode(cimaResponse.body);
        
        final medicine = Medicine(
          cn: cn,
          name: cimaData['nombre'] ?? '',
          quantity: quantity,
          type: type,
          frequency: frequency.toString(),
          dose: doseQuantity.toString(),
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
}


//TODO Hacer una funcion para rescartar la informacion de una medicina en CIMA dada el cn
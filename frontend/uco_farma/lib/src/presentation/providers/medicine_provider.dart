import 'package:flutter/material.dart';
import '../../domain/services/medicine_service.dart';

class MedicineProvider extends ChangeNotifier {
  final _medicineService = MedicineService();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> addMedicine(String userId, String cn, String token, int quantity, String type, int frequency, int doseQuantity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _medicineService.addMedicine(userId, cn, token, quantity, type, frequency, doseQuantity);
      
      if (result['success']) {
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

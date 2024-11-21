import 'package:flutter/material.dart';
import '../../domain/services/medicine_service.dart';
import '../../domain/models/cima_medicine_model.dart';

class MedicineProvider extends ChangeNotifier {
  final _medicineService = MedicineService();
  bool _isLoading = false;
  String? _error;
  CimaMedicine? _cimaMedicine;

  bool get isLoading => _isLoading;
  String? get error => _error;
  CimaMedicine? get cimaMedicine => _cimaMedicine;

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

  Future<bool> getMedicineCimaInfo(String cn) async {
    if (_isLoading) return false;
    
    _cimaMedicine = null;
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _medicineService.getMedicineCimaInfo(cn);
      
      if (result['success']) {
        _cimaMedicine = CimaMedicine.fromJson(result['data']);
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

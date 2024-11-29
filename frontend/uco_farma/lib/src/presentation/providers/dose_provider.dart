import 'package:flutter/material.dart';
import '../../domain/services/dose_service.dart';

class DoseProvider extends ChangeNotifier {
  final _doseService = DoseService();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;


  Future<bool> takeDose(String userId, String cn, int quantity, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _doseService.takeDose(userId, cn, quantity, token);

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

  Future<bool> updateDose(String userId, String cn, int frequency, int quantity, String startDate, String endDate, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _doseService.updateDose(userId, cn, frequency, quantity, token);
      
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

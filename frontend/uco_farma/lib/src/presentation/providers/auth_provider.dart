import 'package:flutter/material.dart';
import '../../domain/models/user_model.dart';
import '../../domain/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loginResult = await _authService.login(email, password);
      
      if (loginResult['success']) {
        final token = loginResult['data']['access_token'];
        
        // Obtener datos del usuario
        final userDataResult = await _authService.getUserData(token);
        
        if (userDataResult['success']) {
          _user = User.fromJson(userDataResult['data']);
          _error = null;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = userDataResult['message'];
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _error = loginResult['message'];
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

  Future<bool> register(String fullName, String email, String password, String birthdate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.register(fullName, email, password, birthdate);
      
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
      _error = 'Error inesperado: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
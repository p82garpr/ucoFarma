import 'package:flutter/material.dart';
import '../../domain/models/user_model.dart';
import '../../domain/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();
  final _prefs = SharedPreferences.getInstance();
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
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
        _token = loginResult['data']['access_token'];

        final userDataResult = await _authService.getUserData(_token!);

        if (userDataResult['success']) {
          _user = User.fromJson(userDataResult['data']);
          _error = null;
          _isLoading = false;
          notifyListeners();

          final prefs = await _prefs;
          await prefs.setString('token', _token!);
          await prefs.setString('email', email);
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

  Future<bool> register(
      String fullName, String email, String password, String birthdate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result =
          await _authService.register(fullName, email, password, birthdate);

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

  Future<void> logout() async {
    _user = null;
    _token = null;
    notifyListeners();

    final prefs = await _prefs;
    await prefs.remove('token');
    await prefs.remove('email');
    
  }

  Future<bool> checkAuthStatus() async {
    final prefs = await _prefs;
    final token = prefs.getString('token');
    
    if (token == null) return false;

    try {
      _token = token;
      final userDataResult = await _authService.getUserData(token);

      if (userDataResult['success']) {
        _user = User.fromJson(userDataResult['data']);
        _error = null;
        notifyListeners();
        return true;
      } else {
        _token = null;
        await prefs.remove('token');
        await prefs.remove('email');
        return false;
      }
    } catch (e) {
      _token = null;
      await prefs.remove('token');
      await prefs.remove('email');
      return false;
    }
  }

  Future<bool> refreshUserData() async {
    if (_token == null) return false;

    try {
      final userDataResult = await _authService.getUserData(_token!);

      if (userDataResult['success']) {
        //formato utf8
        _user = User.fromJson(userDataResult['data']);
        notifyListeners();
        return true;
      } else {
        _error = userDataResult['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

   Future<bool> addShoplist(String cn) async {
    if (_token == null) return false;
    try {
      final result = await _authService.addShoplist(_user!.id, cn, _token!);
      if (result['success']) {
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteShoplist(String cn) async {
    if (_token == null) return false;
    try {
      final result = await _authService.deleteShoplist(_user!.id, cn, _token!);
      if (result['success']) {
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> changePassword(String newPassword) async {
    try {
      if (_token == null) {
        _error = 'No hay sesión activa';
        return false;
      }

      final result = await _authService.changePassword(newPassword, _token!);
      
      if (result['success']) {
        _error = null;
        return true;
      } else {
        _error = result['message'].toString();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
  
}

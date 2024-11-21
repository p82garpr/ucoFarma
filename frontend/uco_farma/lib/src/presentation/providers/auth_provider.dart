import 'package:flutter/material.dart';
import '../../domain/models/user_model.dart';
import '../../domain/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();

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

  void logout() {
    _user = null;
    _token = null;
    notifyListeners();
  }

  Future<bool> refreshUserData() async {
    if (_token == null) return false;

    try {
      final userDataResult = await _authService.getUserData(_token!);

      if (userDataResult['success']) {
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
}

import 'package:flutter/material.dart';
import '../../domain/services/shoplist_service.dart';

class ShoplistProvider extends ChangeNotifier {
  final _shoplistService = ShoplistService();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> addToShoplist(String userId, String cn, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _shoplistService.addToShoplist(userId, cn, token);
      
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

  Future<bool> deleteFromShoplist(String userId, String cn, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _shoplistService.deleteFromShoplist(userId, cn, token);
      
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
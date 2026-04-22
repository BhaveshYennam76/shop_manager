import 'package:flutter/foundation.dart';
import 'package:shop_manager/data/database/database_helper.dart';
import 'package:shop_manager/data/models/shop_model.dart';

class ShopProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Shop> _shops = [];
  bool _isLoading = false;
  String? _error;

  // getters
  List<Shop> get shops => List.unmodifiable(_shops);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _shops.isEmpty;

  // loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // error state
  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  // fetch shops
  Future<void> fetchShops() async {
    _setLoading(true);
    _setError(null);
    try {
      _shops = await _db.fetchAllShops();
    } catch (e) {
      _setError('Failed to load shops: $e');
    } finally {
      _setLoading(false);
    }
  }

  // add shop
  Future<bool> addShop(Shop shop) async {
    try {
      await _db.insertShop(shop);
      await fetchShops();
      return true;
    } catch (e) {
      _setError('Failed to add shop: $e');
      return false;
    }
  }

  // update shop
  Future<bool> updateShop(Shop shop) async {
    try {
      await _db.updateShop(shop);
      await fetchShops();
      return true;
    } catch (e) {
      _setError('Failed to update shop: $e');
      return false;
    }
  }

  // delete shop
  Future<bool> deleteShop(int id) async {
    try {
      await _db.deleteShop(id);

      // remove locally for quick UI update
      _shops.removeWhere((s) => s.id == id);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to delete shop: $e');
      return false;
    }
  }

  // clear error
  void clearError() => _setError(null);
}
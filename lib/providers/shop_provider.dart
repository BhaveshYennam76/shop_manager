import 'package:flutter/foundation.dart';
import 'package:shop_manager/data/database/database_helper.dart';
import 'package:shop_manager/data/models/shop_model.dart';

/// Manages the shop list state and exposes CRUD methods.
/// Uses [ChangeNotifier] so widgets rebuild when data changes.
class ShopProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Shop> _shops = [];
  bool _isLoading = false;
  String? _error;

  // ── Getters ───────────────────────────────────────────────────────────────

  List<Shop> get shops => List.unmodifiable(_shops);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _shops.isEmpty;

  // ── Private Helpers ───────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Loads all shops from the database into [_shops].
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

  /// Inserts a new [Shop] and refreshes the list.
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

  /// Updates an existing [Shop] and refreshes the list.
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

  /// Deletes the shop with [id] and refreshes the list.
  Future<bool> deleteShop(int id) async {
    try {
      await _db.deleteShop(id);
      // Optimistically remove from list for instant UI feedback.
      _shops.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete shop: $e');
      return false;
    }
  }

  /// Clears any stored error message.
  void clearError() => _setError(null);
}

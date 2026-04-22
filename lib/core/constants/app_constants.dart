/// App-wide constants used throughout the application.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'My Shops';
  static const String appVersion = '1.0.0';

  // Database
  static const String dbName = 'shop_manager.db';
  static const int dbVersion = 1;
  static const String tableShops = 'shops';

  // Shop Table Columns
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colAddress = 'address';
  static const String colMobile = 'mobile';
  static const String colEmail = 'email';
  static const String colDescription = 'description';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Splash Duration
  static const Duration splashDuration = Duration(seconds: 2);
}

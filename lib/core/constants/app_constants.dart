class AppConstants {
  AppConstants._(); // no instance

  // app
  static const String appName = 'My Shops';
  static const String appVersion = '1.0.0';

  // db
  static const String dbName = 'shop_manager.db';
  static const int dbVersion = 1;
  static const String tableShops = 'shops';

  // columns
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colAddress = 'address';
  static const String colMobile = 'mobile';
  static const String colEmail = 'email';
  static const String colDescription = 'description';

  // animations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // splash
  static const Duration splashDuration = Duration(seconds: 2);
}
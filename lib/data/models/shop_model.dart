import 'package:shop_manager/core/constants/app_constants.dart';

class Shop {
  final int? id;
  final String name;
  final String address;
  final String mobile;
  final String email;
  final String description;

  const Shop({
    this.id,
    required this.name,
    required this.address,
    required this.mobile,
    required this.email,
    required this.description,
  });

  // map -> object
  factory Shop.fromMap(Map<String, dynamic> map) {
    return Shop(
      id: map[AppConstants.colId] as int?,
      name: map[AppConstants.colName] as String,
      address: map[AppConstants.colAddress] as String,
      mobile: map[AppConstants.colMobile] as String,
      email: map[AppConstants.colEmail] as String,
      description: map[AppConstants.colDescription] as String,
    );
  }

  // object -> map
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      AppConstants.colName: name,
      AppConstants.colAddress: address,
      AppConstants.colMobile: mobile,
      AppConstants.colEmail: email,
      AppConstants.colDescription: description,
    };
    if (id != null) {
      map[AppConstants.colId] = id;
    }
    return map;
  }

  // copy with changes
  Shop copyWith({
    int? id,
    String? name,
    String? address,
    String? mobile,
    String? email,
    String? description,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      description: description ?? this.description,
    );
  }

  @override
  String toString() =>
      'Shop(id: $id, name: $name, address: $address, mobile: $mobile, '
          'email: $email, description: $description)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Shop && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
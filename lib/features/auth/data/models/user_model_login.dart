

import 'package:rento/features/auth/domain/entites/user_entity.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.type,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      username: json['username'],
      email: json['email'],
      type: json['type'].toString(),
    );
  }
}

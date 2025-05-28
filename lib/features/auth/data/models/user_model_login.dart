

import 'package:rento/features/auth/domain/entites/login_user_entity.dart';

class UserModelLogin extends LoginUserEntity {
  UserModelLogin({
    required super.id,
    required super.username,
    required super.email,
    required super.type,
  });

  factory UserModelLogin.fromJson(Map<String, dynamic> json) {
    return UserModelLogin(
      id: json['id'].toString(),
      username: json['username'],
      email: json['email'],
      type: json['type'].toString(),
    );
  }
}

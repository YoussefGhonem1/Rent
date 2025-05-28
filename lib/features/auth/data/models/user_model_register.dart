
import 'package:rento/features/auth/domain/entites/register_user_entity.dart';

class UserModelRegister extends RegisterUserEntity {
  UserModelRegister({
    required super.username,
    required super.email,
    required super.password,
    required super.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'type': type,
    };
  }
}
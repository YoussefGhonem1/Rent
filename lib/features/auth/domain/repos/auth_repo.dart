import 'package:rento/features/auth/domain/entites/user_entity.dart';

abstract class AuthRepository {
  Future<User?> login(String email, String password);
}

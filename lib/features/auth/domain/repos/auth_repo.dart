import 'package:rento/features/auth/domain/entites/login_user_entity.dart';
import 'package:rento/features/auth/domain/entites/register_user_entity.dart';

abstract class AuthRepository {
  Future<LoginUserEntity?> login(String email, String password);
  Future<void> register(RegisterUserEntity user);
}

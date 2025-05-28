import 'package:rento/features/auth/domain/entites/login_user_entity.dart';
import 'package:rento/features/auth/domain/repos/auth_repo.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<LoginUserEntity?> call(String email, String password) {
    return repository.login(email, password);
  }
}

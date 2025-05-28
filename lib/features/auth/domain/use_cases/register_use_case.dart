import 'package:rento/features/auth/domain/entites/register_user_entity.dart';
import 'package:rento/features/auth/domain/repos/auth_repo.dart';



class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<void> call(RegisterUserEntity user) async {
    await repository.register(user);
  }
}
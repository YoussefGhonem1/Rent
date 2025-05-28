
import 'package:rento/features/auth/data/models/user_model_register.dart';
import 'package:rento/features/auth/data/remote_data_source/login_remote_datasource.dart';
import 'package:rento/features/auth/data/remote_data_source/register_remote_data_source.dart';
import 'package:rento/features/auth/domain/entites/login_user_entity.dart';
import 'package:rento/features/auth/domain/entites/register_user_entity.dart';
import 'package:rento/features/auth/domain/repos/auth_repo.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LoginRemoteDataSource loginremoteDataSource;
  final RegisterRemoteDataSource registerremoteDataSource;

  AuthRepositoryImpl(this.loginremoteDataSource, this.registerremoteDataSource);

  @override
  Future<LoginUserEntity?> login(String email, String password) {
    return loginremoteDataSource.login(email, password);
  }

   Future<void> register(RegisterUserEntity user) async {
    final model = UserModelRegister(
      username: user.username,
      email: user.email,
      password: user.password,
      type: user.type,
    );
    await registerremoteDataSource.register(model);
  }
}


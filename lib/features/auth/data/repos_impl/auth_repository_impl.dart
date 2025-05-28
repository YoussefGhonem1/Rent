
import 'package:rento/features/auth/data/remote_data_source/auth_remote_datasource.dart';
import 'package:rento/features/auth/domain/entites/user_entity.dart';
import 'package:rento/features/auth/domain/repos/auth_repo.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<User?> login(String email, String password) {
    return remoteDataSource.login(email, password);
  }
}

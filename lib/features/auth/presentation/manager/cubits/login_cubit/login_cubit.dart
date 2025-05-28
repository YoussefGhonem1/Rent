import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rento/features/auth/domain/entites/login_user_entity.dart';
import 'package:rento/features/auth/domain/use_cases/login_use_case.dart';

part 'login_state.dart';
class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;

  LoginCubit(this.loginUseCase) : super(LoginInitial());

  void login(String email, String password, ) async {
    emit(LoginLoading());
    try {
      final user = await loginUseCase(email, password);
      if (user != null) {
        emit(LoginSuccess(user));
      } else {
        emit(LoginFailure('Invalid credentials'));
      }
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
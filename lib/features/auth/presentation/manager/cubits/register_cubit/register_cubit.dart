import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rento/features/auth/domain/entites/register_user_entity.dart';
import 'package:rento/features/auth/domain/use_cases/register_use_case.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUseCase registerUser;

  RegisterCubit(this.registerUser) : super(RegisterInitial());

  Future<void> register(RegisterUserEntity user) async {
    emit(RegisterLoading());
    try {
      await registerUser(user);
      emit(RegisterSuccess());
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }
}
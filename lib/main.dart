import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:rento/crud.dart';
import 'package:rento/features/auth/data/remote_data_source/register_remote_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rento/features/auth/data/remote_data_source/login_remote_datasource.dart';

import 'package:rento/features/auth/data/repos_impl/auth_repository_impl.dart';

import 'package:rento/features/auth/domain/use_cases/login_use_case.dart';
import 'package:rento/features/auth/domain/use_cases/register_use_case.dart';

import 'package:rento/features/auth/presentation/manager/cubits/login_cubit/login_cubit.dart';
import 'package:rento/features/auth/presentation/manager/cubits/register_cubit/register_cubit.dart';

import 'owner/home_owner.dart';
import 'admin/home_admin.dart';
import 'features/auth/presentation/views/login_screen.dart';

late SharedPreferences sharedPref;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPref = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final httpClient = http.Client();

    final loginDataSource = AuthRemoteDataSourceImpl(httpClient);
    final registerDataSource = RegisterRemoteDataSource(Crud());

    final authRepository = AuthRepositoryImpl(loginDataSource, registerDataSource);

    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginCubit>(
          create: (_) => LoginCubit(LoginUseCase(authRepository)),
        ),
        BlocProvider<RegisterCubit>(
          create: (_) => RegisterCubit(RegisterUseCase(authRepository)),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: sharedPref.getString("id") == null
            ? const LoginScreen()
            : sharedPref.getString("type") == "admin"
                ? const HomeAdmin()
                : const HomeOwner(),
      ),
    );
  }
}

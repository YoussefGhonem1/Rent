import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rento/features/auth/data/remote_data_source/auth_remote_datasource.dart';
import 'package:rento/features/auth/data/repos_impl/auth_repository_impl.dart';
import 'package:rento/features/auth/domain/use_cases/login_use_case.dart';
import 'package:rento/features/auth/presentation/manager/cubits/login_cubit/login_cubit.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginCubit>(
          create: (_) => LoginCubit(
            LoginUseCase(
              AuthRepositoryImpl(
                AuthRemoteDataSourceImpl(http.Client()),
              ),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: sharedPref.getString("id") == null
            ? LoginScreen()
            : sharedPref.getString("type") == "admin"
                ? HomeAdmin()
                : HomeOwner(),
      ),
    );
  }
}

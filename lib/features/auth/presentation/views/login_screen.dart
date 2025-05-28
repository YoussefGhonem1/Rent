// lib/auth/presentation/views/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/admin/home_admin.dart';
import 'package:rento/owner/home_owner.dart';
import 'package:rento/features/auth/presentation/views/widgets/login_form.dart';
import 'package:rento/features/auth/presentation/views/widgets/login_header.dart';
import 'package:rento/features/auth/presentation/manager/cubits/login_cubit/login_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          final type = state.user.type;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => type == "admin" ? const HomeAdmin() : const HomeOwner(),
            ),
          );
        }

        if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("فشل تسجيل الدخول")),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.teal[50],
          body: Center(
            child: state is LoginLoading
                ? const CircularProgressIndicator()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const LoginHeader(),
                        LoginForm(
                          emailController: emailController,
                          passwordController: passwordController,
                          formKey: _formKey,
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

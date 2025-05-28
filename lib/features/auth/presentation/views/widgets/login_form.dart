// lib/auth/presentation/views/widgets/login_form.dart

import 'package:flutter/material.dart';
import 'package:rento/features/auth/presentation/views/widgets/custom_text_form_field.dart';

import 'package:rento/features/auth/presentation/views/widgets/login_button.dart';
import 'package:rento/features/auth/presentation/views/widgets/register_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/features/auth/presentation/manager/cubits/login_cubit/login_cubit.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomTextFormField(
            controller: emailController,
            label: "بريد إلكتروني",
            icon: Icons.email,
          ),
          const SizedBox(height: 20),
          CustomTextFormField(
            controller: passwordController,
            label: "كلمة المرور",
            icon: Icons.lock,
            obscureText: true,
          ),
          const SizedBox(height: 30),
          LoginButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                context.read<LoginCubit>().login(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
              }
            },
          ),
          const SizedBox(height: 20),
          const RegisterButton(),
        ],
      ),
    );
  }
}

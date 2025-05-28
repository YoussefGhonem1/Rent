import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/features/auth/domain/entites/register_user_entity.dart';
import 'package:rento/features/auth/presentation/manager/cubits/register_cubit/register_cubit.dart';


import 'custom_text_form_field.dart';
import 'role_selector.dart';
import 'submit_button.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? selectedRole;

  void _submitForm() {
    if (_formKey.currentState!.validate() && selectedRole != null) {
      final user = RegisterUserEntity(
        username: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        type: selectedRole!,
      );
      context.read<RegisterCubit>().register(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text(
            "إنشاء حسابك",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal[900]),
          ),
          const SizedBox(height: 8),
          Text(
            "انضم إلينا لتجربة صيفية لا نهاية لها",
            style: TextStyle(fontSize: 18, color: Colors.teal[900]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          CustomTextFormField(
            controller: nameController,
            label: "الاسم الكامل",
            icon: Icons.person,
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          RoleSelector(
            selectedRole: selectedRole,
            onChanged: (role) => setState(() => selectedRole = role),
          ),
          const SizedBox(height: 20),
          SubmitButton(onPressed: _submitForm),
        ],
      ),
    );
  }
}

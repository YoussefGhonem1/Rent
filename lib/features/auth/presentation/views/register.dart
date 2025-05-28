import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rento/features/auth/presentation/manager/cubits/register_cubit/register_cubit.dart';
import 'widgets/register_form.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            Navigator.pop(context);
          } else if (state is RegisterFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is RegisterLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 130),
            child: Center(child: RegisterForm()),
          );
        },
      ),
    );
  }
}

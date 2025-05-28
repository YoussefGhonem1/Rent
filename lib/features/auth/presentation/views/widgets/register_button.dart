// lib/auth/presentation/views/widgets/register_button.dart

import 'package:flutter/material.dart';
import 'package:rento/features/auth/register.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const RegisterScreen(),
          ),
        );
      },
      child: Text(
        "ليس لديك حساب؟ سجل الآن",
        style: TextStyle(
          color: Colors.teal[900],
          fontSize: 16,
        ),
      ),
    );
  }
}

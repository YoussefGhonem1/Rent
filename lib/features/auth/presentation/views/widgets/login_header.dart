// lib/auth/presentation/views/widgets/login_header.dart

import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "مرحبًا بعودتك",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.teal[900],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "قم بتسجيل الدخول لمواصلة رحلتك الصيفية",
          style: TextStyle(
            fontSize: 18,
            color: Colors.teal[900],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

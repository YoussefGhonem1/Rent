// lib/core/widgets/custom_text_form_field.dart

import 'package:flutter/material.dart';
import 'package:rento/valid.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: (val) => validInput(val!, 3, 30),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.teal[900]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.teal[900]),
      ),
    );
  }
}

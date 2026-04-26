import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AuthTextField({
    super.key,
    required this.label,
    this.obscureText = false,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
    );
  }
}

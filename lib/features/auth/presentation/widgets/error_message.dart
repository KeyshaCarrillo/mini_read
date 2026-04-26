import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String? message;
  const ErrorMessage({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(message!, style: const TextStyle(color: Colors.red)),
    );
  }
}

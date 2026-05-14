// Flutter imports:
import 'package:flutter/material.dart';

/// Reusable error/message banner for displaying alerts and errors
class ErrorBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const ErrorBanner({required this.message, this.isError = true, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: isError ? Colors.red.shade100 : Colors.orange.shade100,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isError ? Colors.red : Colors.orange,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

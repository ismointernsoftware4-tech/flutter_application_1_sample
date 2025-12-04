import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Centralized text input for the app.
/// Use this instead of TextField / TextFormField directly in screens.
class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    required this.controller,
    this.placeholder = '',
    this.multiline = false,
    this.obscureText = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String placeholder;
  final bool multiline;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return ShadInput(
      controller: controller,
      placeholder: Text(placeholder),
      minLines: multiline ? 3 : 1,
      maxLines: multiline ? 5 : 1,
      obscureText: obscureText,
      onChanged: onChanged,
    );
  }
}



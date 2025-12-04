import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Centralized button for the app.
/// Wrap this instead of using ElevatedButton / TextButton / ShadButton directly.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.outline = false,
    this.destructive = false,
    this.fullWidth = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool outline;
  final bool destructive;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    Widget button;
    if (destructive) {
      button = ShadButton.destructive(onPressed: onPressed, child: child);
    } else if (outline) {
      button = ShadButton.outline(onPressed: onPressed, child: child);
    } else {
      button = ShadButton(onPressed: onPressed, child: child);
    }

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}



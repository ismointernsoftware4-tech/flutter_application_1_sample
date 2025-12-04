import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Centralized card for panels and list items.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}



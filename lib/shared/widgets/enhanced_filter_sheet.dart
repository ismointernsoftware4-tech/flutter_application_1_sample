import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/responsive_helper.dart';

/// Enhanced filter sheet that adapts to screen size
/// - Mobile: Enhanced bottom sheet with drag handle and better styling
/// - Desktop/Tablet: Side drawer that slides in from the right
class EnhancedFilterSheet<T> extends StatelessWidget {
  const EnhancedFilterSheet({
    super.key,
    required this.title,
    required this.child,
    required this.onApply,
    required this.onClear,
    this.height,
    this.width,
  });

  final String title;
  final Widget child;
  final T Function() onApply;
  final T Function() onClear;
  final double? height;
  final double? width;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    required T Function() onApply,
    required T Function() onClear,
    double? height,
    double? width,
  }) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    if (isMobile) {
      // Mobile: Show as enhanced bottom sheet
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => EnhancedFilterSheet<T>(
          title: title,
          child: child,
          onApply: onApply,
          onClear: onClear,
          height: height,
        ),
      );
    } else {
      // Desktop/Tablet: Show as side drawer
      return showDialog<T>(
        context: context,
        barrierColor: Colors.black54,
        builder: (context) => Dialog(
          alignment: Alignment.centerRight,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: EnhancedFilterSheet<T>(
            title: title,
            child: child,
            onApply: onApply,
            onClear: onClear,
            width: width ?? 420,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final screenHeight = MediaQuery.of(context).size.height;

    if (isMobile) {
      // Mobile: Enhanced bottom sheet design
      return Container(
        height: height ?? screenHeight * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header with title and close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: child,
              ),
            ),
            // Footer with action buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: ShadButton.outline(
                        onPressed: () => Navigator.of(context).pop(onClear()),
                        child: const Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ShadButton(
                        onPressed: () => Navigator.of(context).pop(onApply()),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
        .animate()
        .slideY(begin: 1.0, end: 0.0, duration: 300.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 300.ms);
    } else {
      // Desktop/Tablet: Side drawer design
      return Container(
        width: width ?? 420,
        height: screenHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with colored background
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                    color: Colors.grey[700],
                  ),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: child,
              ),
            ),
            // Footer with action buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ShadButton.outline(
                      onPressed: () => Navigator.of(context).pop(onClear()),
                      child: const Text(
                        'Clear All',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ShadButton(
                      onPressed: () => Navigator.of(context).pop(onApply()),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
        .animate()
        .slideX(begin: 1.0, end: 0.0, duration: 300.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 300.ms);
    }
  }
}


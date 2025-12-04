import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Reusable filter button widget
class FilterButton extends StatelessWidget {
  const FilterButton({
    super.key,
    required this.onFilterPressed,
    this.label = 'Filter',
    this.icon = Icons.filter_alt,
    this.style,
    this.isFullWidth = false,
  });

  final VoidCallback onFilterPressed;
  final String label;
  final IconData icon;
  final ButtonStyle? style;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final button = ShadButton.outline(
      onPressed: onFilterPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    )
      .animate()
      .fadeIn(duration: 200.ms);

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

/// Reusable export button widget
class ExportButton extends StatelessWidget {
  const ExportButton({
    super.key,
    required this.onExportPressed,
    this.label = 'Export',
    this.icon = Icons.download,
    this.style,
    this.isFullWidth = false,
    this.successMessage,
    this.errorMessage,
  });

  final Future<String> Function() onExportPressed;
  final String label;
  final IconData icon;
  final ButtonStyle? style;
  final bool isFullWidth;
  final String? successMessage;
  final String? errorMessage;

  Future<void> _handleExport(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final message = await onExportPressed();
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(successMessage ?? message)),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'Export failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = ShadButton.outline(
      onPressed: () => _handleExport(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    )
      .animate()
      .fadeIn(duration: 200.ms);

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

/// Container widget that holds both filter and export buttons
/// Handles responsive layout (mobile vs desktop)
class FilterExportButtonRow extends StatelessWidget {
  const FilterExportButtonRow({
    super.key,
    required this.onFilterPressed,
    required this.onExportPressed,
    this.filterLabel = 'Filter',
    this.exportLabel = 'Export',
    this.isMobile = false,
    this.spacing = 12,
  });

  final VoidCallback onFilterPressed;
  final Future<String> Function() onExportPressed;
  final String filterLabel;
  final String exportLabel;
  final bool isMobile;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: [
          FilterButton(
            onFilterPressed: onFilterPressed,
            label: filterLabel,
            isFullWidth: true,
          ),
          SizedBox(height: spacing),
          ExportButton(
            onExportPressed: onExportPressed,
            label: exportLabel,
            isFullWidth: true,
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FilterButton(onFilterPressed: onFilterPressed, label: filterLabel),
        SizedBox(width: spacing),
        ExportButton(onExportPressed: onExportPressed, label: exportLabel),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../utils/responsive_helper.dart';

class FormScreenLayout extends StatelessWidget {
  const FormScreenLayout({
    super.key,
    required this.title,
    required this.body,
    this.onBack,
    this.trailing,
    this.showDefaultSearch = true,
    this.searchHint = 'Search...',
  });

  final String title;
  final Widget body;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool showDefaultSearch;
  final String searchHint;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final horizontalPadding = isMobile ? 16.0 : 32.0;
    final verticalPadding = isMobile ? 16.0 : 32.0;

    return Column(
      children: [
        _Header(
          title: title,
          onBack: onBack,
          trailing: trailing,
          showDefaultSearch: showDefaultSearch,
          searchHint: searchHint,
          horizontalPadding: horizontalPadding,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: body,
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.horizontalPadding,
    this.onBack,
    this.trailing,
    this.showDefaultSearch = true,
    this.searchHint = 'Search...',
  });

  final String title;
  final double horizontalPadding;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool showDefaultSearch;
  final String searchHint;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: isMobile ? 12 : 16,
    );
    final Widget? trailingWidget = trailing ??
        (showDefaultSearch ? _SearchField(hint: searchHint) : null);

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: isMobile
          ? _MobileHeader(
              title: title,
              onBack: onBack,
              trailing: trailingWidget,
            )
          : _DesktopHeader(
              title: title,
              onBack: onBack,
              trailing: trailingWidget,
            ),
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader({
    required this.title,
    this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _BackButton(onBack: onBack),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 16),
          trailing!,
        ],
      ],
    );
  }
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader({
    required this.title,
    this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BackButton(onBack: onBack),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(height: 12),
          trailing!,
        ],
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return ShadButton.outline(
      onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_back, size: 18),
          SizedBox(width: 8),
          Text('Back'),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final width = ResponsiveHelper.getSearchBarWidth(context);

    final field = Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: ShadInput(
        placeholder: Text(hint),
      ),
    );

    if (isMobile) {
      return field;
    }

    return SizedBox(
      width: width,
      child: field,
    );
  }
}


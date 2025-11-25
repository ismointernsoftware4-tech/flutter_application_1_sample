import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Screen size checks
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // Get responsive padding
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(12);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(20);
    }
  }

  // Get responsive font size
  static double getTitleFontSize(BuildContext context) {
    if (isMobile(context)) {
      return 18;
    } else if (isTablet(context)) {
      return 22;
    } else {
      return 24;
    }
  }

  // Get responsive width for columns
  static double getColumnWidth(BuildContext context, int columns) {
    final width = MediaQuery.of(context).size.width;
    final padding = getScreenPadding(context);
    final availableWidth = width - (padding.horizontal * 2);
    
    if (columns == 2) {
      return isMobile(context) ? availableWidth : (availableWidth - 16) / 2;
    } else if (columns == 3) {
      if (isMobile(context)) return availableWidth;
      if (isTablet(context)) return (availableWidth - 32) / 2;
      return (availableWidth - 32) / 3;
    }
    return availableWidth;
  }

  // Get responsive search bar width
  static double getSearchBarWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 240;
    } else {
      return 300;
    }
  }

  // Get responsive sidebar width
  static double getSidebarWidth(BuildContext context) {
    if (isMobile(context)) {
      return MediaQuery.of(context).size.width * 0.9;
    } else if (isTablet(context)) {
      return 500;
    } else {
      return 600;
    }
  }

  // Get responsive width with constraints
  static double getResponsiveWidth(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
    double? maxWidth,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isMobile(context)) {
      return mobile ?? screenWidth;
    } else if (isTablet(context)) {
      return tablet ?? (maxWidth ?? screenWidth);
    } else {
      return desktop ?? (maxWidth ?? screenWidth);
    }
  }
}



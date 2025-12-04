import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/reports_models.dart';
import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/utils/responsive_helper.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          _header(context),
          Expanded(
            child: SingleChildScrollView(
              padding: ResponsiveHelper.getScreenPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryRow(provider.reportSummaries),
                  const SizedBox(height: 24),
                  _reportGrid(provider.reportCategories),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenPadding = ResponsiveHelper.getScreenPadding(context);
    final searchWidth = ResponsiveHelper.getSearchBarWidth(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenPadding.horizontal,
        vertical: isMobile ? 16 : 20,
      ),
      decoration: const BoxDecoration(color: Colors.white),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final isSmallScreen = screenWidth < 700;
          
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (isMobile || isTablet)
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      tooltip: 'Open menu',
                    ),
                  if (!isSmallScreen)
                    Text(
                      'Reports & Analytics',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getTitleFontSize(context),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                ],
              ),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isSmallScreen ? double.infinity : searchWidth,
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryRow(List<ReportSummary> summaries) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: summaries
          .asMap()
          .entries
          .map(
            (entry) => Container(
              width: 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.value.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.value.value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
              .animate()
              .fadeIn(duration: 400.ms, delay: (entry.key * 100).ms)
              .slideY(begin: -0.1, end: 0)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
          )
          .toList(),
    );
  }

  Widget _reportGrid(List<ReportCategory> categories) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width;
        if (constraints.maxWidth >= 1200) {
          width = (constraints.maxWidth - 32) / 3;
        } else if (constraints.maxWidth >= 800) {
          width = (constraints.maxWidth - 16) / 2;
        } else {
          width = constraints.maxWidth;
        }
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: categories
              .asMap()
              .entries
              .map(
                (entry) => SizedBox(
                  width: width,
                  child: _categoryCard(entry.value)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: (entry.key * 150).ms)
                    .slideX(begin: -0.1, end: 0)
                    .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _categoryCard(ReportCategory category) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Text(
                category.groupTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            category.description,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ...category.reports.asMap().entries.map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.value.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.value.subtitle,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.download),
                  ),
                ],
              ),
            )
              .animate()
              .fadeIn(duration: 300.ms, delay: (entry.key * 50).ms)
              .slideX(begin: 0.05, end: 0),
          ),
        ],
      ),
    );
  }
}


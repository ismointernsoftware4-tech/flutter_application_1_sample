import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dashboard_models.dart';
import '../providers/approvals_provider.dart';
import '../providers/dashboard_provider.dart';
import '../utils/responsive_helper.dart';

class ApprovalsScreen extends StatelessWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ApprovalsFilterProvider(),
      child: const _ApprovalsView(),
    );
  }
}

class _ApprovalsView extends StatelessWidget {
  const _ApprovalsView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final filter = context.watch<ApprovalsFilterProvider>().activeFilter;

    final items = provider.approvalWorkflows.where((item) {
      if (filter == 'All') return true;
      return item.status.toLowerCase() == filter.toLowerCase();
    }).toList();

    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          _header(context, provider.approvalWorkflows.length),
          Expanded(
            child: SingleChildScrollView(
              padding: ResponsiveHelper.getScreenPadding(context),
              child: Column(
                children: items.map(_workflowCard).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, int pendingCount) {
    final filterProvider = context.watch<ApprovalsFilterProvider>();
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
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
                          'Approval Workflows',
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
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = ResponsiveHelper.isMobile(context);
              
              if (isMobile) {
                // Wrap tabs on mobile
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(filterProvider.tabs.length, (index) {
                        final isActive = filterProvider.activeIndex == index;
                        return GestureDetector(
                          onTap: () => filterProvider.setActiveIndex(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isActive
                                    ? Colors.blue
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Text(
                              filterProvider.tabs[index],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: isActive ? Colors.blue : Colors.grey[600],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.timelapse, color: Colors.blueGrey, size: 18),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Pending Actions: $pendingCount',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                // Original Row for desktop/tablet
                return Row(
                  children: [
                    ...List.generate(filterProvider.tabs.length, (index) {
                      final isActive = filterProvider.activeIndex == index;
                      return GestureDetector(
                        onTap: () => filterProvider.setActiveIndex(index),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isActive
                                  ? Colors.blue
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Text(
                            filterProvider.tabs[index],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isActive ? Colors.blue : Colors.grey[600],
                            ),
                          ),
                        ),
                      );
                    }),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.timelapse, color: Colors.blueGrey),
                        const SizedBox(width: 6),
                        Text(
                          'Pending Actions: $pendingCount',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _workflowCard(ApprovalWorkflowItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              _priorityChip(item.priority),
              const SizedBox(width: 12),
              Text(
                item.id,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '•',
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(width: 8),
              Text(item.date),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 6),
          Text(
            'Requested by ${item.requestedBy}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = ResponsiveHelper.isMobile(context);
              
              if (isMobile) {
                // Stack vertically on mobile
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _actionButton(Icons.check_circle, 'Approve', Colors.green),
                    const SizedBox(height: 8),
                    _actionButton(Icons.close, 'Reject', Colors.red),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.remove_red_eye_outlined),
                      label: const Text('View'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blueGrey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0ECFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.status,
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              } else {
                // Original Row for desktop/tablet
                return Row(
                  children: [
                    Flexible(
                      child: _actionButton(Icons.check_circle, 'Approve', Colors.green),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: _actionButton(Icons.close, 'Reject', Colors.red),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.remove_red_eye_outlined),
                        label: const Text('View'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blueGrey[700],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0ECFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.status,
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _priorityChip(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'routine':
        color = Colors.blue;
        break;
      case 'high':
        color = Colors.orange;
        break;
      case 'urgent':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: color, size: 18),
      label: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}


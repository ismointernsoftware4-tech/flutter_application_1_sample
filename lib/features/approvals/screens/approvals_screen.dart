import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../models/approvals_models.dart';
import '../providers/approvals_provider.dart';
import '../../../shared/providers/dashboard_provider.dart';
import '../../../shared/utils/responsive_helper.dart';
import '../../../shared/widgets/approval_card.dart';

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
    final filterProvider = context.watch<ApprovalsFilterProvider>();
    final filter = filterProvider.activeFilter;

    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          StreamBuilder<List<ApprovalWorkflowItem>>(
            stream: provider.approvalWorkflowsStream,
            builder: (context, snapshot) {
              final pendingCount = snapshot.data?.where((item) => 
                item.status.toLowerCase() == 'pending' || 
                item.status.toLowerCase() == 'pending approval'
              ).length ?? 0;
              return _header(context, pendingCount);
            },
          ),
          Expanded(
            child: StreamBuilder<List<ApprovalWorkflowItem>>(
              stream: provider.approvalWorkflowsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading approvals: ${snapshot.error}'),
                  );
                }

                final allItems = snapshot.data ?? const <ApprovalWorkflowItem>[];
                final items = allItems.where((item) {
                  if (filter == 'All') return true;
                  
                  final itemStatus = item.status.toLowerCase();
                  final filterStatus = filter.toLowerCase();
                  
                  // Handle "Pending" filter to match both "Pending" and "Pending Approval"
                  if (filterStatus == 'pending') {
                    return itemStatus == 'pending' || itemStatus == 'pending approval';
                  }
                  
                  // For other filters (Approved, Rejected), do exact match
                  return itemStatus == filterStatus;
                }).toList();

                if (items.isEmpty) {
                  return const Center(
                    child: Text('No approval workflows found.'),
                  );
                }

                return SingleChildScrollView(
                  padding: ResponsiveHelper.getScreenPadding(context),
                  child: Column(
                    children: items.asMap().entries
                        .map(
                          (entry) => ApprovalCard(
                            item: entry.value,
                            onApprove: () async {
                              try {
                                // Decide whether we are approving a PR or a PO
                                if (entry.value.title == 'Purchase Order') {
                                  await provider.approvePO(entry.value.prDocumentId);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('PO approved successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } else {
                                  await provider.approvePR(entry.value.prDocumentId);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('PR approved successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error approving item: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            onReject: () async {
                              try {
                                if (entry.value.title == 'Purchase Order') {
                                  await provider.rejectPO(entry.value.prDocumentId);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('PO rejected successfully'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                } else {
                                  await provider.rejectPR(entry.value.prDocumentId);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('PR rejected successfully'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error rejecting item: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            onView: () {
                              // TODO: navigate to PR/PO details if needed
                            },
                          )
                              .animate()
                              .fadeIn(
                                duration: 400.ms,
                                delay: (entry.key * 100).ms,
                              )
                              .slideX(begin: -0.1, end: 0)
                              .scale(
                                begin: const Offset(0.95, 0.95),
                                end: const Offset(1, 1),
                              ),
                        )
                        .toList(),
                  ),
                );
              },
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
}
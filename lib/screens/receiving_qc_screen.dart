import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dashboard_models.dart';
import '../providers/dashboard_provider.dart';
import '../utils/responsive_helper.dart';

class ReceivingQcScreen extends StatelessWidget {
  const ReceivingQcScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final padding = ResponsiveHelper.getScreenPadding(context);
    final tasks = provider.receivingTasksForTab(provider.receivingTabIndex);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      color: Colors.grey[100],
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: isDesktop ? 1180 : null,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: padding.left,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _BreadcrumbBar(),
                const SizedBox(height: 16),
                _HeaderRow(onNewReceipt: () {}),
                const SizedBox(height: 24),
                _TabSelector(
                  tabs: provider.receivingTabs,
                  activeIndex: provider.receivingTabIndex,
                  onTabSelected: provider.setReceivingTabIndex,
                ),
                const SizedBox(height: 24),
                _QueueCard(
                  title: _sectionTitle(provider.receivingTabIndex),
                  subtitle: _sectionSubtitle(provider.receivingTabIndex),
                  tasks: tasks,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _sectionTitle(int index) {
    switch (index) {
      case 1:
        return 'Quality Control Queue';
      case 2:
        return 'Put-Away Assignments';
      default:
        return 'Pending Receipts';
    }
  }

  static String _sectionSubtitle(int index) {
    switch (index) {
      case 1:
        return 'Items requiring QC check before release to inventory.';
      case 2:
        return 'Receipts that still need storage locations assigned.';
      default:
        return 'Purchase orders expected for delivery.';
    }
  }
}

class _BreadcrumbBar extends StatelessWidget {
  const _BreadcrumbBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            Text(
              'Main Lab',
              style: TextStyle(
                color: Colors.blueGrey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
            const Text(
              'Receiving & QC',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.qr_code_scanner, size: 18),
          label: const Text('Scan Item'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blueGrey.shade700,
            side: BorderSide(color: Colors.blueGrey.shade200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.onNewReceipt});

  final VoidCallback onNewReceipt;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final titleStyle = TextStyle(
      fontSize: ResponsiveHelper.getTitleFontSize(context) + 2,
      fontWeight: FontWeight.w700,
      color: Colors.blueGrey.shade900,
    );
    final subtitleStyle = TextStyle(
      color: Colors.blueGrey.shade600,
      fontSize: 15,
    );

    final button = ElevatedButton.icon(
      onPressed: onNewReceipt,
      icon: const Icon(Icons.inventory_2_outlined),
      label: const Text('New Receipt (GRN)'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0057B7),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    );

    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Receiving & QC', style: titleStyle),
                  const SizedBox(height: 8),
                  Text(
                    'Process incoming shipments, quality control, and put-away.',
                    style: subtitleStyle,
                  ),
                  const SizedBox(height: 16),
                  button,
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Receiving & QC', style: titleStyle),
                        const SizedBox(height: 8),
                        Text(
                          'Process incoming shipments, quality control, and put-away.',
                          style: subtitleStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  button,
                ],
              ),
      ),
    );
  }
}

class _TabSelector extends StatelessWidget {
  const _TabSelector({
    required this.tabs,
    required this.activeIndex,
    required this.onTabSelected,
  });

  final List<String> tabs;
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(tabs.length, (index) {
          final isActive = index == activeIndex;
          return GestureDetector(
            onTap: () => onTabSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF002855) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF002855)
                      : Colors.grey.shade200,
                ),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.blueGrey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  const _QueueCard({
    required this.title,
    required this.subtitle,
    required this.tasks,
  });

  final String title;
  final String subtitle;
  final List<ReceivingTask> tasks;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          if (tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'Nothing queued for this step.',
                  style: TextStyle(color: Colors.black45),
                ),
              ),
            )
          else
            Column(
              children: [
                for (var i = 0; i < tasks.length; i++) ...[
                  _QueueItem(task: tasks[i]),
                  if (i != tasks.length - 1) const SizedBox(height: 16),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _QueueItem extends StatelessWidget {
  const _QueueItem({required this.task});

  final ReceivingTask task;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    final actionButtons = Row(
      mainAxisAlignment:
          isMobile ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
      children: [
        if (task.secondaryLabel != null)
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  task.secondaryColor ?? Colors.blueGrey.shade700,
              side: BorderSide(
                color: (task.secondaryColor ?? Colors.blueGrey.shade200)
                    .withOpacity(0.8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(task.secondaryLabel!),
          ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: task.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(task.primaryLabel),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(task.icon, color: Colors.blueGrey.shade700),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.reference,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.meta,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (task.itemTags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: task.itemTags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.description_outlined,
                              size: 14, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 16),
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                actionButtons,
              ],
            )
          else
            Align(
              alignment: Alignment.centerRight,
              child: actionButtons,
            ),
        ],
      ),
    );
  }
}


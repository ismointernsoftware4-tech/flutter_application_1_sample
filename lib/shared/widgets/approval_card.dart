import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../features/approvals/models/approvals_models.dart';

class ApprovalCard extends StatelessWidget {
  final ApprovalWorkflowItem item;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onView;

  const ApprovalCard({
    super.key,
    required this.item,
    this.onApprove,
    this.onReject,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(item.status);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return ShadCard(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _priorityChip(item.priority),
                SizedBox(width: isMobile ? 8 : 12),
                Flexible(
                  child: Text(
                    item.id,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                      fontSize: isMobile ? 12 : 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (!isMobile) ...[
                  const Spacer(),
                  Text(
                    item.date,
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
            if (isMobile) ...[
              const SizedBox(height: 8),
              Text(
                item.date,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              item.title,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: Colors.grey[700],
              ),
              maxLines: isMobile ? 2 : null,
              overflow: isMobile ? TextOverflow.ellipsis : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Requested by ${item.requestedBy}',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      color: const Color(0xFF4B5563),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: isMobile ? 8 : 12,
              runSpacing: isMobile ? 8 : 0,
              children: [
                ShadButton(
                  onPressed: onApprove,
                  child: const Text('Approve'),
                ),
                ShadButton.outline(
                  onPressed: onReject,
                  child: const Text('Reject'),
                ),
                if (onView != null)
                  ShadButton.ghost(
                    onPressed: onView,
                    child: const Text('View'),
                  ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.05, end: 0)
        .scale(begin: const Offset(0.97, 0.97), end: const Offset(1, 1));
  }

  Widget _priorityChip(String priority) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'urgent':
        color = Colors.red;
        break;
      case 'high':
        color = Colors.orange;
        break;
      default:
        color = Colors.blueGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        priority,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }
}



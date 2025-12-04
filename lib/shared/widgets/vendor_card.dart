import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../features/vendor_management/models/vendor_models.dart';

class VendorCard extends StatelessWidget {
  final Vendor vendor;
  final VoidCallback? onView;
  final VoidCallback? onEdit;

  const VendorCard({
    super.key,
    required this.vendor,
    this.onView,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(vendor.status);

    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vendor.category,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  vendor.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _infoRow(Icons.person_outline, vendor.contactName),
          const SizedBox(height: 8),
          _infoRow(Icons.email_outlined, vendor.email),
          const SizedBox(height: 8),
          _infoRow(Icons.phone_outlined, vendor.phone),
          const SizedBox(height: 16),
          Row(
            children: [
              _textIconButton(
                icon: Icons.remove_red_eye_outlined,
                label: 'View',
                onTap: onView,
              ),
              const SizedBox(width: 12),
              _textIconButton(
                icon: Icons.edit_outlined,
                label: 'Edit',
                onTap: onEdit,
              ),
            ],
          ),
        ],
        ),
      ),
    )
      .animate()
      .fadeIn(duration: 400.ms)
      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 400.ms);
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF3C3C43),
            ),
          ),
        ),
      ],
    );
  }

  Widget _textIconButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return ShadButton.outline(
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.shade600;
      case 'pending':
        return Colors.orange.shade700;
      case 'rejected':
        return Colors.red.shade600;
      case 'urgent':
        return Colors.red.shade400;
      default:
        return Colors.blueGrey;
    }
  }
}


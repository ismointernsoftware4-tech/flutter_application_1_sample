import 'package:flutter/material.dart';

import '../models/dynamic_form_models.dart';

class ToolboxPanel extends StatelessWidget {
  const ToolboxPanel({
    super.key,
    required this.onAddField,
    this.activeSectionTitle,
    required this.hasSections,
  });

  final void Function(DynamicFieldType type) onAddField;
  final String? activeSectionTitle;
  final bool hasSections;

  @override
  Widget build(BuildContext context) {
    final items = [
      _ToolItem('Text', Icons.text_fields, DynamicFieldType.text),
      _ToolItem('Number', Icons.pin, DynamicFieldType.number),
      _ToolItem('Email', Icons.email_outlined, DynamicFieldType.email),
      _ToolItem(
        'Dropdown',
        Icons.arrow_drop_down_circle,
        DynamicFieldType.dropdown,
      ),
      _ToolItem(
        'Checkbox',
        Icons.check_box_outlined,
        DynamicFieldType.checkbox,
      ),
      _ToolItem(
        'Radio',
        Icons.radio_button_checked_outlined,
        DynamicFieldType.radio,
      ),
      _ToolItem('Date', Icons.calendar_today_outlined, DynamicFieldType.date),
      _ToolItem('Textarea', Icons.notes_outlined, DynamicFieldType.textarea),
      _ToolItem('File Upload', Icons.upload_file, DynamicFieldType.file),
      _ToolItem('Section Title', Icons.title, DynamicFieldType.section),
      _ToolItem('Divider', Icons.horizontal_rule, DynamicFieldType.divider),
    ];

    return Container(
      color: const Color(0xFFF7F8FA),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Field Controls',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (!hasSections)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Add a section before dropping fields.',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else if (activeSectionTitle != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Adding to: ${activeSectionTitle!.toUpperCase()}',
                style: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                return Draggable<DynamicFieldType>(
                  data: item.type,
                  feedback: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 20,
                            color: Colors.blueGrey[700],
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item.label,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onAddField(item.type),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: Colors.blueGrey[700],
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item.label,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolItem {
  final String label;
  final IconData icon;
  final DynamicFieldType type;

  const _ToolItem(this.label, this.icon, this.type);
}


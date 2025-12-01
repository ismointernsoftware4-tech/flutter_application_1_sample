import 'package:flutter/material.dart';

import '../models/dynamic_form_models.dart';

class FieldPreview extends StatelessWidget {
  const FieldPreview({
    super.key,
    required this.field,
    required this.isSelected,
  });

  final DynamicFormField field;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF2563EB)
              : Colors.grey.withOpacity(0.25),
          width: isSelected ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              Icon(
                _iconForType(field.type),
                size: 18,
                color: const Color(0xFF2563EB),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  field.label.isEmpty ? '(No label)' : field.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPreviewBody(context),
          if ((field.extra['helpText'] as String?)?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                field.extra['helpText'] as String,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreviewBody(BuildContext context) {
    switch (field.type) {
      case DynamicFieldType.text:
      case DynamicFieldType.email:
        return _inputPreview(
          context,
          placeholder: field.hint.isNotEmpty
              ? field.hint
              : 'Enter ${field.label}',
          icon: field.type == DynamicFieldType.email
              ? Icons.alternate_email
              : Icons.text_fields,
        );
      case DynamicFieldType.number:
        final format = (field.extra['numberFormat'] as String?) ?? 'integer';
        return _inputPreview(
          context,
          placeholder: format == 'integer' ? '123' : '123.45',
          icon: Icons.pin,
          trailingText: format == 'integer' ? 'int' : 'float',
        );
      case DynamicFieldType.dropdown:
        return _dropdownPreview();
      case DynamicFieldType.checkbox:
        return _checkboxPreview();
      case DynamicFieldType.radio:
        return _radioPreview();
      case DynamicFieldType.date:
        return _inputPreview(
          context,
          placeholder: 'dd/mm/yyyy',
          icon: Icons.calendar_today_outlined,
        );
      case DynamicFieldType.textarea:
        return _textareaPreview();
      case DynamicFieldType.file:
        return _filePreview();
      case DynamicFieldType.section:
      case DynamicFieldType.divider:
        return const SizedBox.shrink();
    }
  }

  Widget _inputPreview(
    BuildContext context, {
    required String placeholder,
    IconData? icon,
    String? trailingText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.black45),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              placeholder,
              style: const TextStyle(color: Colors.black38, fontSize: 13),
            ),
          ),
          if (trailingText != null)
            Text(
              trailingText,
              style: const TextStyle(color: Colors.black45, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _dropdownPreview() {
    final options = _previewOptions();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: Row(
            children: const [
              Expanded(
                child: Text(
                  'Select an option',
                  style: TextStyle(color: Colors.black38, fontSize: 13),
                ),
              ),
              Icon(Icons.expand_more, color: Colors.black38),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options
              .map(
                (option) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Text(option, style: const TextStyle(fontSize: 12)),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _checkboxPreview() {
    return Row(
      children: [
        Checkbox(value: field.extra['defaultChecked'] == true, onChanged: null),
        Expanded(
          child: Text(
            field.label.isEmpty ? 'Checkbox option' : field.label,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _radioPreview() {
    final options = _previewOptions();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options
          .map(
            (option) => Row(
              children: [
                Radio<String>(value: option, groupValue: null, onChanged: null),
                Expanded(child: Text(option)),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _textareaPreview() {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          field.hint.isNotEmpty ? field.hint : 'Type your response...',
          style: const TextStyle(color: Colors.black38),
        ),
      ),
    );
  }

  Widget _filePreview() {
    final allowed =
        (field.extra['allowedTypes'] as List?)?.cast<String>() ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: Row(
            children: const [
              Icon(Icons.upload_file, color: Colors.black45),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Upload File',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
        if (allowed.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Allowed: ${allowed.join(', ')}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
      ],
    );
  }

  List<String> _previewOptions() {
    final options = field.options;
    if (options.isEmpty) {
      return const ['Option 1', 'Option 2'];
    }
    return options.take(3).toList();
  }

  IconData _iconForType(DynamicFieldType type) {
    switch (type) {
      case DynamicFieldType.text:
        return Icons.text_fields;
      case DynamicFieldType.email:
        return Icons.alternate_email;
      case DynamicFieldType.number:
        return Icons.pin;
      case DynamicFieldType.dropdown:
        return Icons.list;
      case DynamicFieldType.checkbox:
        return Icons.check_box_outlined;
      case DynamicFieldType.radio:
        return Icons.radio_button_checked;
      case DynamicFieldType.date:
        return Icons.calendar_month_outlined;
      case DynamicFieldType.textarea:
        return Icons.notes;
      case DynamicFieldType.file:
        return Icons.upload_file;
      case DynamicFieldType.section:
      case DynamicFieldType.divider:
        return Icons.view_week;
    }
  }
}


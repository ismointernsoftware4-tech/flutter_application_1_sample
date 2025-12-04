import 'package:flutter/material.dart';

import '../models/dynamic_form_models.dart';
import 'field_preview.dart';

class FormCanvas extends StatelessWidget {
  const FormCanvas({
    super.key,
    required this.sections,
    required this.selectedSectionId,
    required this.selectedFieldId,
    required this.onReorderSections,
    required this.onMoveField,
    required this.onSelectSection,
    required this.onSelectField,
    required this.onAddField,
  });

  final List<DynamicFormSection> sections;
  final String? selectedSectionId;
  final String? selectedFieldId;
  final void Function(int oldIndex, int newIndex) onReorderSections;
  final void Function({
    required String fromSectionId,
    required String toSectionId,
    required String fieldId,
    required int targetIndex,
  })
  onMoveField;
  final void Function(String sectionId) onSelectSection;
  final void Function(String sectionId, String fieldId) onSelectField;
  final void Function(DynamicFieldType type, String? sectionId) onAddField;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const Center(
        child: Text(
          'Start by adding a section, then drag fields from the toolbox.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      itemCount: sections.length,
      onReorder: onReorderSections,
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        final section = sections[index];
        return _SectionCard(
          key: ValueKey(section.id),
          section: section,
          isSelected: section.id == selectedSectionId,
          selectedFieldId: selectedFieldId,
          onSelectSection: () => onSelectSection(section.id),
          onSelectField: (fieldId) => onSelectField(section.id, fieldId),
          onMoveField: onMoveField,
          onAddField: (type) => onAddField(type, section.id),
          dragHandle: ReorderableDragStartListener(
            index: index,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: const Icon(Icons.drag_indicator, color: Colors.blueGrey),
            ),
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatefulWidget {
  const _SectionCard({
    required super.key,
    required this.section,
    required this.dragHandle,
    required this.isSelected,
    required this.selectedFieldId,
    required this.onSelectSection,
    required this.onSelectField,
    required this.onMoveField,
    required this.onAddField,
  });

  final DynamicFormSection section;
  final Widget dragHandle;
  final bool isSelected;
  final String? selectedFieldId;
  final VoidCallback onSelectSection;
  final void Function(String fieldId) onSelectField;
  final void Function({
    required String fromSectionId,
    required String toSectionId,
    required String fieldId,
    required int targetIndex,
  })
  onMoveField;
  final void Function(DynamicFieldType type) onAddField;

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: DragTarget<Object>(
          onWillAccept: (data) {
            if (data is _FieldDragPayload) {
              // Only accept field drops from other sections
              return data.sectionId != widget.section.id;
            }
            // Allow toolbox field types
            return data is DynamicFieldType;
          },
          onAccept: (data) {
            if (data is _FieldDragPayload) {
              // Move field from another section to the end of this section
              widget.onMoveField(
                fromSectionId: data.sectionId,
                toSectionId: widget.section.id,
                fieldId: data.fieldId,
                targetIndex: widget.section.fields.length,
              );
            } else if (data is DynamicFieldType) {
              // Add new field from toolbox
              widget.onAddField(data);
            }
          },
          builder: (context, candidateData, rejectedData) {
            final isActive = candidateData.isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected || isActive
                      ? const Color(0xFF2563EB)
                      : Colors.transparent,
                  width: widget.isSelected || isActive ? 1.4 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isHovering ? 0.08 : 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onSelectSection,
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.section.title.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              if (widget.section.description.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    widget.section.description,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      widget.dragHandle,
                    ],
                  ),
                  const SizedBox(height: 20),
                  _FieldsGrid(
                    sectionId: widget.section.id,
                    fields: widget.section.fields,
                    selectedFieldId: widget.selectedFieldId,
                    onSelectField: widget.onSelectField,
                    onMoveField: widget.onMoveField,
                    onAddField: widget.onAddField,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FieldsGrid extends StatelessWidget {
  const _FieldsGrid({
    required this.sectionId,
    required this.fields,
    required this.selectedFieldId,
    required this.onSelectField,
    required this.onMoveField,
    required this.onAddField,
  });

  final String sectionId;
  final List<DynamicFormField> fields;
  final String? selectedFieldId;
  final void Function(String fieldId) onSelectField;
  final void Function({
    required String fromSectionId,
    required String toSectionId,
    required String fieldId,
    required int targetIndex,
  })
  onMoveField;
  final void Function(DynamicFieldType type) onAddField;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 24.0;
        final availableWidth = constraints.maxWidth;
        final columnWidth = ((availableWidth - (gap * 2)) / 3).clamp(
          220.0,
          availableWidth,
        );

        final children = <Widget>[];
        for (var i = 0; i < fields.length; i++) {
          final field = fields[i];
          final currentIndex = i;
          children.add(
            SizedBox(
              width: columnWidth,
              child: _FieldCard(
                sectionId: sectionId,
                field: field,
                isSelected: selectedFieldId == field.id,
                onSelectField: () => onSelectField(field.id),
                onMoveField: (payload) {
                  // Calculate correct target index for reordering
                  int targetIndex = currentIndex;
                  
                  if (payload.sectionId == sectionId) {
                    // Dragging within the same section
                    final sourceIndex = fields.indexWhere(
                      (f) => f.id == payload.fieldId,
                    );
                    if (sourceIndex == -1) return;
                    
                    if (sourceIndex == currentIndex) {
                      // Dropping on itself, no change needed
                      return;
                    }
                    
                    // When moving backward (sourceIndex > targetIndex), 
                    // we insert at targetIndex (which is correct)
                    // When moving forward (sourceIndex < targetIndex),
                    // we need to insert at targetIndex
                    // The reorderFields method will handle the index adjustment
                    targetIndex = currentIndex;
                  }
                  
                  onMoveField(
                    fromSectionId: payload.sectionId,
                    toSectionId: sectionId,
                    fieldId: payload.fieldId,
                    targetIndex: targetIndex,
                  );
                },
                onAddField: onAddField,
              ),
            ),
          );
        }
        // Drop zone at end - accepts both field payloads and field types
        children.add(
          SizedBox(
            width: columnWidth,
            child: DragTarget<Object>(
              onWillAccept: (_) => true,
              onAccept: (data) {
                if (data is _FieldDragPayload) {
                  onMoveField(
                    fromSectionId: data.sectionId,
                    toSectionId: sectionId,
                    fieldId: data.fieldId,
                    targetIndex: fields.length,
                  );
                } else if (data is DynamicFieldType) {
                  onAddField(data);
                }
              },
              builder: (context, candidateData, rejectedData) {
                final isActive = candidateData.isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 90,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.blue.withOpacity(0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive ? Colors.blue : Colors.grey.withOpacity(0.2),
                      style: BorderStyle.solid,
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Drop here',
                      style: TextStyle(color: Colors.black38, fontSize: 12),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        return Wrap(spacing: gap, runSpacing: gap, children: children);
      },
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.sectionId,
    required this.field,
    required this.onSelectField,
    required this.onMoveField,
    required this.isSelected,
    required this.onAddField,
  });

  final String sectionId;
  final DynamicFormField field;
  final bool isSelected;
  final VoidCallback onSelectField;
  final void Function(_FieldDragPayload payload) onMoveField;
  final void Function(DynamicFieldType type) onAddField;

  @override
  Widget build(BuildContext context) {
    final preview = FieldPreview(field: field, isSelected: isSelected);

    return Draggable<_FieldDragPayload>(
      data: _FieldDragPayload(sectionId: sectionId, fieldId: field.id),
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(width: 220, child: preview),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: preview),
      onDragStarted: onSelectField,
      child: DragTarget<Object>(
        onWillAccept: (data) {
          if (data is _FieldDragPayload) {
            // Don't accept if dropping on itself
            return data.fieldId != field.id;
          }
          // Accept field types from toolbox
          return data is DynamicFieldType;
        },
        onAccept: (data) {
          if (data is _FieldDragPayload) {
            onMoveField(data);
          } else if (data is DynamicFieldType) {
            onAddField(data);
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isActive = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: InkWell(
              onTap: onSelectField,
              borderRadius: BorderRadius.circular(14),
              child: preview,
            ),
          );
        },
      ),
    );
  }
}


class _FieldDragPayload {
  const _FieldDragPayload({required this.sectionId, required this.fieldId});

  final String sectionId;
  final String fieldId;
}


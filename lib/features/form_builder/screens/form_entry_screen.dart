import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/dynamic_form/dynamic_form_widget.dart';
import '../models/dynamic_form_models.dart';
import '../providers/form_builder_provider.dart';
import 'form_builder_screen.dart';

class FormEntryScreen extends StatefulWidget {
  const FormEntryScreen({
    super.key,
    required this.formTitle,
    this.clinicId,
    this.clinicName,
  });

  final String formTitle;
  final String? clinicId;
  final String? clinicName;

  @override
  State<FormEntryScreen> createState() => _FormEntryScreenState();
}

class _FormEntryScreenState extends State<FormEntryScreen> {
  DynamicFormDefinition? _definition;
  bool _isLoading = true;
  late final String _baseFormId;

  @override
  void initState() {
    super.initState();
    _baseFormId = _baseFormIdForTitle(widget.formTitle);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDefinition());
  }

  String get _formId =>
      widget.clinicId != null ? '${widget.clinicId}_$_baseFormId' : _baseFormId;

  Future<void> _loadDefinition() async {
    setState(() => _isLoading = true);
    try {
      final formBuilderProvider = context.read<FormBuilderProvider>();
      DynamicFormDefinition? data = await formBuilderProvider
          .fetchDefinitionById(_formId);
      data ??=
          await formBuilderProvider.fetchDefinitionFromAsset(_formId) ??
          await formBuilderProvider.fetchDefinitionById(_baseFormId) ??
          await formBuilderProvider.fetchDefinitionFromAsset(_baseFormId);
      data ??= defaultDynamicFormDefinition();
      if (!mounted) return;
      setState(() {
        _definition = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _definition == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _openFormBuilder(context),
                  icon: const Icon(Icons.build_outlined),
                  label: const Text('Customize Form'),
                ),
              ),
              const SizedBox(height: 8),
              DynamicFormWidget(
                definition: _definition!,
                title: widget.formTitle,
                description: widget.clinicName != null
                    ? 'Fill out the ${widget.formTitle.toLowerCase()} for ${widget.clinicName}.'
                    : 'Fill out the ${widget.formTitle.toLowerCase()}.',
                onSave: (data) async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${widget.formTitle} saved${widget.clinicName != null ? ' for ${widget.clinicName}' : ''}.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _baseFormIdForTitle(String formTitle) {
    final key = formTitle.toLowerCase();
    if (key.contains('procurement')) return 'form_procurement';
    if (key.contains('purchase order') || key.contains('po')) {
      return 'form_purchase_order';
    }
    if (key.contains('vendor')) return 'form_vendor';
    if (key.contains('grn')) return 'form_grn';
    if (key.contains('receiving')) return 'form_receiving';
    if (key.contains('location')) return 'form_add_location';
    if (key.contains('adjustment')) return 'form_adjustment';
    if (key.contains('internal')) return 'form_internal_transfer';
    if (key.contains('branch')) return 'form_branch_transfer';
    if (key.contains('consumption')) return 'form_consumption';
    return 'form_add_item';
  }

  Future<void> _openFormBuilder(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => FormBuilderProvider(
            formId: _formId,
            clinicId: widget.clinicId,
          ),
          child: FormBuilderScreen(formTitle: widget.formTitle),
        ),
      ),
    );
    if (!mounted) return;
    await _loadDefinition();
  }
}


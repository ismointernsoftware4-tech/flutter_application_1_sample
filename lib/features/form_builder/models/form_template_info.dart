class FormTemplateInfo {
  final String id;
  final String title;
  final String assetKey;

  const FormTemplateInfo({
    required this.id,
    required this.title,
    required this.assetKey,
  });
}

const List<FormTemplateInfo> kFormTemplates = [
  FormTemplateInfo(
    id: 'form_add_item',
    title: 'Add Item Form',
    assetKey: 'item_master',
  ),
  FormTemplateInfo(
    id: 'form_procurement',
    title: 'Procurement Form',
    assetKey: 'purchase_requisition',
  ),
  FormTemplateInfo(
    id: 'form_purchase_order',
    title: 'Purchase Order Form',
    assetKey: 'purchase_order',
  ),
  FormTemplateInfo(id: 'form_grn', title: 'GRN Form', assetKey: 'grn'),
  FormTemplateInfo(id: 'form_vendor', title: 'Vendor Form', assetKey: 'vendor'),
];

FormTemplateInfo? formTemplateById(String formId) {
  for (final template in kFormTemplates) {
    if (template.id == formId) return template;
  }
  return null;
}


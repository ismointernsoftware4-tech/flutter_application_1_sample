class ApprovalWorkflowItem {
  final String priority;
  final String id;
  final String date;
  final String title;
  final String description;
  final String requestedBy;
  final String status;
  final String prDocumentId; // Original Firebase document ID for updating

  const ApprovalWorkflowItem({
    required this.priority,
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.requestedBy,
    required this.status,
    required this.prDocumentId,
  });
}


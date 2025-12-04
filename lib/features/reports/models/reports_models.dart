class ReportSummary {
  final String label;
  final String value;

  const ReportSummary({required this.label, required this.value});
}

class ReportDownload {
  final String title;
  final String subtitle;

  const ReportDownload({required this.title, required this.subtitle});
}

class ReportCategory {
  final String groupTitle;
  final String description;
  final List<ReportDownload> reports;

  const ReportCategory({
    required this.groupTitle,
    required this.description,
    required this.reports,
  });
}


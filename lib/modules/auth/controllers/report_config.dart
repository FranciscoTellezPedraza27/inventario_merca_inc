class ReportConfig {
  final String title;
  final String collection;
  final List<String> headers;
  final List<String> fields;

  const ReportConfig({
    required this.title,
    required this.collection,
    required this.headers,
    required this.fields,
  });
}
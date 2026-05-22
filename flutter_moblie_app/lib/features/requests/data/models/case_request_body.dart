class CaseRequestBody {
  final String description;
  final String dateTime; // "2026-03-10T15:30:00"

  CaseRequestBody({
    required this.description,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'dateTime': dateTime,
    };
  }
}

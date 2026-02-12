class CaseRequestBody {
  final String description; // Specialization or Details
  final String date;
  final String time;
  final String location;
  final String specialization;

  CaseRequestBody({
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.specialization,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'date': date,
      'time': time,
      'location': location,
      'specialization': specialization,
    };
  }
}

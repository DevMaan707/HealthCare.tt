import 'package:intl/intl.dart';

class MedicalHistory {
  final int? id;
  final String condition;
  final String diagnosis;
  final DateTime diagnosisDate;
  final String treatment;
  final String medications;

  MedicalHistory({
    this.id,
    required this.condition,
    required this.diagnosis,
    required this.diagnosisDate,
    required this.treatment,
    required this.medications,
  });

  factory MedicalHistory.fromJson(Map<String, dynamic> json) {
    return MedicalHistory(
      id: json['id'],
      condition: json['condition'],
      diagnosis: json['diagnosis'],
      diagnosisDate: DateTime.parse(json['diagnosisDate']),
      treatment: json['treatment'],
      medications: json['medications'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condition': condition,
      'diagnosis': diagnosis,
      'diagnosisDate': DateFormat('yyyy-MM-dd').format(diagnosisDate),
      'treatment': treatment,
      'medications': medications,
    };
  }
}

import 'package:physigest/features/patients/domain/models/patient_activity.dart';

class PatientActivityModel extends PatientActivity {
  const PatientActivityModel({
    required super.id,
    required super.patientId,
    required super.userId,
    required super.type,
    required super.description,
    required super.date,
    super.metadata,
  });

  factory PatientActivityModel.fromJson(Map<String, dynamic> json) {
    return PatientActivityModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] != null 
          ? DateTime.parse(json['date']).toLocal() 
          : DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

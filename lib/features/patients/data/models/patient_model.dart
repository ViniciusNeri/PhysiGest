import 'package:physigest/features/patients/domain/models/patient.dart';
import 'anamnesis_model.dart';

class PatientModel extends Patient {
  const PatientModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.birthDate,
    required super.gender,
    required super.profession,
    super.completedAppointments = 0,
    super.noShowAppointments = 0,
    super.nextAppointmentDate,
    super.anamnesis = const Anamnesis(),
    super.photoPaths = const [],
    super.pin = '',
    super.status = 'active',
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    final anamnesisJson = json['anamnesis'] as Map<String, dynamic>? ?? {};
    final photosJson = json['photoPaths'] as List<dynamic>? ?? [];

    return PatientModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      birthDate: json['birthDate'] ?? '',
      gender: json['gender'] ?? 'Não especificado',
      profession: json['profession'] ?? json['occupation'] ?? '',
      completedAppointments: json['completedAppointments'] ?? 0,
      noShowAppointments: json['noShowAppointments'] ?? 0,
      nextAppointmentDate: json['nextAppointmentDate'],
      anamnesis: AnamnesisModel.fromJson(anamnesisJson),
      photoPaths: photosJson.map((e) => e.toString()).toList(),
      pin: json['pin']?.toString() ?? '',
      status: _mapStatusFromJson(json['status']),
    );
  }

  static String _mapStatusFromJson(dynamic status) {
    if (status == 1 || status == '1' || status == 'active' || status == true) return 'active';
    if (status == 0 || status == '0' || status == 'inactive' || status == false) return 'inactive';
    return 'active'; // fallback
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'birthDate': birthDate,
      'gender': gender,
      'profession': profession,
      'completedAppointments': completedAppointments,
      'noShowAppointments': noShowAppointments,
      'nextAppointmentDate': nextAppointmentDate,
      'anamnesis': AnamnesisModel(
        id: anamnesis.id,
        date: anamnesis.date,
        mainComplaint: anamnesis.mainComplaint,
        currentIllness: anamnesis.currentIllness,
        historic: anamnesis.historic,
        familyHistory: anamnesis.familyHistory,
        lifestyleHabits: anamnesis.lifestyleHabits,
        physicalExam: anamnesis.physicalExam,
        clinicalDiagnosis: anamnesis.clinicalDiagnosis,
        treatmentPlan: anamnesis.treatmentPlan,
        medications: anamnesis.medications,
        weight: anamnesis.weight,
        height: anamnesis.height,
      ).toJson(),
      'status': status == 'active' ? 1 : 0,
    };
  }
}

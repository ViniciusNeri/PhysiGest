import 'package:physigest/features/patients/domain/models/patient.dart';

class PatientModel extends Patient {
  const PatientModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.birthDate,
    required super.occupation,
    super.anamnesis = const Anamnesis(),
    super.photoPaths = const [],
    super.financialHistory = const [],
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    final anamnesisJson = json['anamnesis'] as Map<String, dynamic>? ?? {};
    final photosJson = json['photoPaths'] as List<dynamic>? ?? [];
    final financialJson = json['financialHistory'] as List<dynamic>? ?? [];

    return PatientModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      birthDate: json['birthDate'] ?? '',
      occupation: json['occupation'] ?? '',
      anamnesis: Anamnesis(
        mainComplaint: anamnesisJson['mainComplaint'] ?? '',
        currentIllness: anamnesisJson['currentIllness'] ?? '',
        historic: anamnesisJson['historic'] ?? '',
        familyHistory: anamnesisJson['familyHistory'] ?? '',
        lifestyleHabits: anamnesisJson['lifestyleHabits'] ?? '',
        physicalExam: anamnesisJson['physicalExam'] ?? '',
        clinicalDiagnosis: anamnesisJson['clinicalDiagnosis'] ?? '',
        treatmentPlan: anamnesisJson['treatmentPlan'] ?? '',
        medications: anamnesisJson['medications'] ?? '',
      ),
      photoPaths: photosJson.map((e) => e.toString()).toList(),
      financialHistory: financialJson.map((t) => PaymentTransaction(
        id: t['id']?.toString() ?? '',
        title: t['title'] ?? '',
        serviceType: t['serviceType'] ?? '',
        quantity: t['quantity'] as int? ?? 1,
        date: t['date'] ?? '',
        value: (t['value'] as num?)?.toDouble() ?? 0.0,
        paymentMethod: t['paymentMethod'] ?? '',
        status: t['status'] ?? 'PENDENTE',
      )).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'birthDate': birthDate,
      'occupation': occupation,
      'anamnesis': {
        'mainComplaint': anamnesis.mainComplaint,
        'currentIllness': anamnesis.currentIllness,
        'historic': anamnesis.historic,
        'familyHistory': anamnesis.familyHistory,
        'lifestyleHabits': anamnesis.lifestyleHabits,
        'physicalExam': anamnesis.physicalExam,
        'clinicalDiagnosis': anamnesis.clinicalDiagnosis,
        'treatmentPlan': anamnesis.treatmentPlan,
        'medications': anamnesis.medications,
      },
    };
  }
}

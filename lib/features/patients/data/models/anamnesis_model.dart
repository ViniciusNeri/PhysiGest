import 'package:physigest/features/patients/domain/models/patient.dart';

class AnamnesisModel extends Anamnesis {
  const AnamnesisModel({
    super.id,
    super.date,
    super.mainComplaint,
    super.currentIllness,
    super.historic,
    super.familyHistory,
    super.lifestyleHabits,
    super.physicalExam,
    super.clinicalDiagnosis,
    super.treatmentPlan,
    super.medications,
    super.weight,
    super.height,
  });

  factory AnamnesisModel.fromJson(Map<String, dynamic> json) {
    return AnamnesisModel(
      id: json['id']?.toString() ?? '',
      date: json['date'] ?? '',
      mainComplaint: json['chiefComplaint'] ?? json['mainComplaint'] ?? '',
      currentIllness: json['historyOfPresentIllness'] ?? json['currentIllness'] ?? '',
      historic: json['pastMedicalHistory'] ?? json['historic'] ?? '',
      familyHistory: json['familyHistory'] ?? '',
      lifestyleHabits: json['socialHistory'] ?? json['lifestyleHabits'] ?? '',
      physicalExam: json['physicalExamination'] ?? json['physicalExam'] ?? '',
      clinicalDiagnosis: json['assessment'] ?? json['clinicalDiagnosis'] ?? '',
      treatmentPlan: json['plan'] ?? json['treatmentPlan'] ?? '',
      medications: json['currentMedications'] ?? json['medications'] ?? '',
      weight: json['weight']?.toString() ?? '',
      height: json['height']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.isEmpty ? DateTime.now().toIso8601String() : date,
      'chiefComplaint': mainComplaint,
      'historyOfPresentIllness': currentIllness,
      'pastMedicalHistory': historic,
      'familyHistory': familyHistory,
      'socialHistory': lifestyleHabits,
      'currentMedications': medications,
      'reviewOfSystems': '', // Not mapped yet
      'physicalExamination': physicalExam,
      'assessment': clinicalDiagnosis,
      'plan': treatmentPlan,
      'height': double.tryParse(height.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0,
      'weight': double.tryParse(weight.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0,
      'notes': historic, // Using historic as notes for now
    };
  }

  static AnamnesisModel fromDomain(Anamnesis anamnesis) {
    return AnamnesisModel(
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
    );
  }
}

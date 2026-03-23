import 'package:equatable/equatable.dart';

class PaymentTransaction extends Equatable {
  final String id;
  final String title;
  final String serviceType;
  final int quantity;
  final String date;
  final double value;
  final String paymentMethod;
  final String status; // 'PAGO' or 'PENDENTE'

  const PaymentTransaction({
    required this.id,
    required this.title,
    required this.serviceType,
    required this.quantity,
    required this.date,
    required this.value,
    required this.paymentMethod,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    serviceType,
    quantity,
    date,
    value,
    paymentMethod,
    status,
  ];
}

class Patient extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String birthDate;
  final String occupation;
  final Anamnesis anamnesis;
  final List<String>
  photoPaths; // Lista de caminhos para as fotos locais mockadas
  final List<PaymentTransaction> financialHistory; // Extrato do paciente

  const Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.occupation,
    this.anamnesis = const Anamnesis(),
    this.photoPaths = const [],
    this.financialHistory = const [],
  });

  Patient copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? birthDate,
    String? occupation,
    Anamnesis? anamnesis,
    List<String>? photoPaths,
    List<PaymentTransaction>? financialHistory,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      occupation: occupation ?? this.occupation,
      anamnesis: anamnesis ?? this.anamnesis,
      photoPaths: photoPaths ?? this.photoPaths,
      financialHistory: financialHistory ?? this.financialHistory,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    birthDate,
    occupation,
    anamnesis,
    photoPaths,
    financialHistory,
  ];
}

class Anamnesis extends Equatable {
  final String mainComplaint;
  final String currentIllness;
  final String historic;
  final String familyHistory;
  final String lifestyleHabits;
  final String physicalExam;
  final String clinicalDiagnosis;
  final String treatmentPlan;
  final String medications;

  const Anamnesis({
    this.mainComplaint = '',
    this.currentIllness = '',
    this.historic = '',
    this.familyHistory = '',
    this.lifestyleHabits = '',
    this.physicalExam = '',
    this.clinicalDiagnosis = '',
    this.treatmentPlan = '',
    this.medications = '',
  });

  Anamnesis copyWith({
    String? mainComplaint,
    String? currentIllness,
    String? historic,
    String? familyHistory,
    String? lifestyleHabits,
    String? physicalExam,
    String? clinicalDiagnosis,
    String? treatmentPlan,
    String? medications,
  }) {
    return Anamnesis(
      mainComplaint: mainComplaint ?? this.mainComplaint,
      currentIllness: currentIllness ?? this.currentIllness,
      historic: historic ?? this.historic,
      familyHistory: familyHistory ?? this.familyHistory,
      lifestyleHabits: lifestyleHabits ?? this.lifestyleHabits,
      physicalExam: physicalExam ?? this.physicalExam,
      clinicalDiagnosis: clinicalDiagnosis ?? this.clinicalDiagnosis,
      treatmentPlan: treatmentPlan ?? this.treatmentPlan,
      medications: medications ?? this.medications,
    );
  }

  @override
  List<Object?> get props => [
    mainComplaint,
    currentIllness,
    historic,
    familyHistory,
    lifestyleHabits,
    physicalExam,
    clinicalDiagnosis,
    treatmentPlan,
    medications,
  ];
}

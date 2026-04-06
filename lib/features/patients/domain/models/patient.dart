import 'package:equatable/equatable.dart';

class PatientPayment extends Equatable {
  final String id;
  final String patientId;
  final String userId;
  final String type; // 'income' or 'expense'
  final String category;
  final String description;
  final double amount;
  final String date;
  final String paymentMethod;
  final String status; // 'paid', 'pending', 'overdue'
  final String? dueDate;
  final String? paymentDate;
  final String? notes;
  final int totalSessions;

  const PatientPayment({
    required this.id,
    required this.patientId,
    required this.userId,
    required this.type,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    required this.status,
    this.dueDate,
    this.paymentDate,
    this.notes,
    this.totalSessions = 1,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        userId,
        type,
        category,
        description,
        amount,
        date,
        paymentMethod,
        status,
        dueDate,
        paymentDate,
        notes,
        totalSessions,
      ];
}

class PatientFinancialSummary extends Equatable {
  final double outstandingBalance;
  final int totalSessions;
  final double totalPaidAmount;
  final List<PatientPayment> payments;

  const PatientFinancialSummary({
    this.outstandingBalance = 0,
    this.totalSessions = 0,
    this.totalPaidAmount = 0,
    this.payments = const [],
  });

  @override
  List<Object?> get props =>
      [outstandingBalance, totalSessions, totalPaidAmount, payments];
}

class Patient extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String birthDate;
  final String gender;
  final String profession;
  final int completedAppointments;
  final int noShowAppointments;
  final String? nextAppointmentDate;
  final Anamnesis anamnesis;
  final List<String> photoPaths; // Lista de caminhos para as fotos locais mockadas
  final String pin; // 4-digit PIN for booking access

  const Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.gender,
    required this.profession,
    this.completedAppointments = 0,
    this.noShowAppointments = 0,
    this.nextAppointmentDate,
    this.anamnesis = const Anamnesis(),
    this.photoPaths = const [],
    this.pin = '',
  });

  String get displayBirthDate {
    if (birthDate.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(birthDate).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return birthDate;
    }
  }

  String get displayGender {
    switch (gender.toLowerCase()) {
      case 'male':
      case 'masculino':
        return 'Masculino';
      case 'female':
      case 'feminino':
        return 'Feminino';
      default:
        return 'Outros';
    }
  }

  String get displayNextAppointmentDate {
    if (nextAppointmentDate == null || nextAppointmentDate!.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(nextAppointmentDate!).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
    } catch (_) {
      return nextAppointmentDate!;
    }
  }

  String get displayAge {
    if (birthDate.isEmpty) return 'Idade N/A';
    try {
      final date = DateTime.parse(birthDate).toLocal();
      final today = DateTime.now();
      int currentAge = today.year - date.year;
      if (today.month < date.month ||
          (today.month == date.month && today.day < date.day)) {
        currentAge--;
      }
      return '$currentAge anos';
    } catch (_) {
      try {
        final parts = birthDate.split('/');
        if (parts.length == 3) {
          final date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          final today = DateTime.now();
          int currentAge = today.year - date.year;
          if (today.month < date.month ||
              (today.month == date.month && today.day < date.day)) {
            currentAge--;
          }
          return '$currentAge anos';
        }
      } catch (_) {}
      return 'Idade N/A';
    }
  }

  Patient copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? birthDate,
    String? gender,
    String? profession,
    int? completedAppointments,
    int? noShowAppointments,
    String? nextAppointmentDate,
    Anamnesis? anamnesis,
    List<String>? photoPaths,
    String? pin,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      profession: profession ?? this.profession,
      completedAppointments: completedAppointments ?? this.completedAppointments,
      noShowAppointments: noShowAppointments ?? this.noShowAppointments,
      nextAppointmentDate: nextAppointmentDate ?? this.nextAppointmentDate,
      anamnesis: anamnesis ?? this.anamnesis,
      photoPaths: photoPaths ?? this.photoPaths,
      pin: pin ?? this.pin,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    birthDate,
    gender,
    profession,
    completedAppointments,
    noShowAppointments,
    nextAppointmentDate,
    anamnesis,
    photoPaths,
    pin,
  ];
}

class Anamnesis extends Equatable {
  final String id;
  final String date;
  final String mainComplaint;
  final String currentIllness;
  final String historic;
  final String familyHistory;
  final String lifestyleHabits;
  final String physicalExam;
  final String clinicalDiagnosis;
  final String treatmentPlan;
  final String medications;
  final String weight;
  final String height;

  const Anamnesis({
    this.id = '',
    this.date = '',
    this.mainComplaint = '',
    this.currentIllness = '',
    this.historic = '',
    this.familyHistory = '',
    this.lifestyleHabits = '',
    this.physicalExam = '',
    this.clinicalDiagnosis = '',
    this.treatmentPlan = '',
    this.medications = '',
    this.weight = '',
    this.height = '',
  });

  Anamnesis copyWith({
    String? id,
    String? date,
    String? mainComplaint,
    String? currentIllness,
    String? historic,
    String? familyHistory,
    String? lifestyleHabits,
    String? physicalExam,
    String? clinicalDiagnosis,
    String? treatmentPlan,
    String? medications,
    String? weight,
    String? height,
  }) {
    return Anamnesis(
      id: id ?? this.id,
      date: date ?? this.date,
      mainComplaint: mainComplaint ?? this.mainComplaint,
      currentIllness: currentIllness ?? this.currentIllness,
      historic: historic ?? this.historic,
      familyHistory: familyHistory ?? this.familyHistory,
      lifestyleHabits: lifestyleHabits ?? this.lifestyleHabits,
      physicalExam: physicalExam ?? this.physicalExam,
      clinicalDiagnosis: clinicalDiagnosis ?? this.clinicalDiagnosis,
      treatmentPlan: treatmentPlan ?? this.treatmentPlan,
      medications: medications ?? this.medications,
      weight: weight ?? this.weight,
      height: height ?? this.height,
    );
  }

  @override
  List<Object?> get props => [
    id,
    date,
    mainComplaint,
    currentIllness,
    historic,
    familyHistory,
    lifestyleHabits,
    physicalExam,
    clinicalDiagnosis,
    treatmentPlan,
    medications,
    weight,
    height,
  ];
}

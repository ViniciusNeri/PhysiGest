import 'package:equatable/equatable.dart';

class Patient extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String birthDate;
  final String occupation;
  final Anamnesis anamnesis;
  final List<String> photoPaths; // Lista de caminhos para as fotos locais mockadas

  const Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.occupation,
    this.anamnesis = const Anamnesis(),
    this.photoPaths = const [],
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
    );
  }

  @override
  List<Object?> get props => [id, name, email, phone, birthDate, occupation, anamnesis, photoPaths];
}

class Anamnesis extends Equatable {
  final String mainComplaint;
  final String historic;
  final String clinicalDiagnosis;
  final String medications;

  const Anamnesis({
    this.mainComplaint = '',
    this.historic = '',
    this.clinicalDiagnosis = '',
    this.medications = '',
  });

  Anamnesis copyWith({
    String? mainComplaint,
    String? historic,
    String? clinicalDiagnosis,
    String? medications,
  }) {
    return Anamnesis(
      mainComplaint: mainComplaint ?? this.mainComplaint,
      historic: historic ?? this.historic,
      clinicalDiagnosis: clinicalDiagnosis ?? this.clinicalDiagnosis,
      medications: medications ?? this.medications,
    );
  }

  @override
  List<Object?> get props => [mainComplaint, historic, clinicalDiagnosis, medications];
}

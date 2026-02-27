import 'package:equatable/equatable.dart';
import 'package:physigest/features/patients/domain/models/patient.dart';

abstract class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object?> get props => [];
}

class LoadPatients extends PatientEvent {}

class AddPatient extends PatientEvent {
  final Patient patient;

  const AddPatient(this.patient);

  @override
  List<Object?> get props => [patient];
}

class UpdatePatient extends PatientEvent {
  final Patient patient;

  const UpdatePatient(this.patient);

  @override
  List<Object?> get props => [patient];
}

class AddPhotoToPatient extends PatientEvent {
  final String patientId;
  final String photoPath;

  const AddPhotoToPatient(this.patientId, this.photoPath);

  @override
  List<Object?> get props => [patientId, photoPath];
}

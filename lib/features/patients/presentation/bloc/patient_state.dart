import 'package:equatable/equatable.dart';
import 'package:physigest/features/patients/domain/models/patient.dart';

enum PatientStatus { initial, loading, success, failure }

class PatientState extends Equatable {
  final PatientStatus status;
  final List<Patient> patients;
  final String? errorMessage;

  const PatientState({
    this.status = PatientStatus.initial,
    this.patients = const [],
    this.errorMessage,
  });

  PatientState copyWith({
    PatientStatus? status,
    List<Patient>? patients,
    String? errorMessage,
  }) {
    return PatientState(
      status: status ?? this.status,
      patients: patients ?? this.patients,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, patients, errorMessage];
}

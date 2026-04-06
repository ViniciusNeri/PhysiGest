import 'package:equatable/equatable.dart';
import 'package:physigest/features/patients/domain/models/patient.dart';

enum PatientStatus { initial, loading, success, failure }

class PatientState extends Equatable {
  final PatientStatus status;
  final List<Patient> patients;
  final String? errorMessage;
  final String? successMessage;

  const PatientState({
    this.status = PatientStatus.initial,
    this.patients = const [],
    this.errorMessage,
    this.successMessage,
  });

  PatientState copyWith({
    PatientStatus? status,
    List<Patient>? patients,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return PatientState(
      status: status ?? this.status,
      patients: patients ?? this.patients,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [status, patients, errorMessage, successMessage];
}

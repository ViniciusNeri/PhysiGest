import 'package:equatable/equatable.dart';
import '../../domain/models/patient.dart';

enum PatientFinancialStatus { initial, loading, success, failure, addingPayment, paymentAdded, statusUpdated }

class PatientFinancialState extends Equatable {
  final PatientFinancialStatus status;
  final PatientFinancialSummary? summary;
  final String? errorMessage;
  final String? successMessage;

  const PatientFinancialState({
    this.status = PatientFinancialStatus.initial,
    this.summary,
    this.errorMessage,
    this.successMessage,
  });

  PatientFinancialState copyWith({
    PatientFinancialStatus? status,
    PatientFinancialSummary? summary,
    String? errorMessage,
    String? successMessage,
    bool clearMessage = false,
  }) {
    return PatientFinancialState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      errorMessage: clearMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessage ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [status, summary, errorMessage, successMessage];
}

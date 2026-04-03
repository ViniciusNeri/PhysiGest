import 'package:equatable/equatable.dart';
import '../../domain/models/patient.dart';

enum PatientFinancialStatus { initial, loading, success, failure, addingPayment, paymentAdded, statusUpdated }

class PatientFinancialState extends Equatable {
  final PatientFinancialStatus status;
  final PatientFinancialSummary? summary;
  final String? errorMessage;

  const PatientFinancialState({
    this.status = PatientFinancialStatus.initial,
    this.summary,
    this.errorMessage,
  });

  PatientFinancialState copyWith({
    PatientFinancialStatus? status,
    PatientFinancialSummary? summary,
    String? errorMessage,
  }) {
    return PatientFinancialState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, summary, errorMessage];
}

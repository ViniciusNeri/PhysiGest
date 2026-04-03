import 'package:equatable/equatable.dart';
import '../../domain/models/patient.dart';

abstract class PatientFinancialEvent extends Equatable {
  const PatientFinancialEvent();

  @override
  List<Object?> get props => [];
}

class LoadFinancialSummary extends PatientFinancialEvent {
  final String patientId;
  const LoadFinancialSummary(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

class AddFinancialPayment extends PatientFinancialEvent {
  final String patientId;
  final PatientPayment payment;

  const AddFinancialPayment({required this.patientId, required this.payment});

  @override
  List<Object?> get props => [patientId, payment];
}

class UpdatePaymentStatus extends PatientFinancialEvent {
  final String patientId;
  final String paymentId;
  final String status;
  final String? paymentMethod;

  const UpdatePaymentStatus({
    required this.patientId,
    required this.paymentId,
    required this.status,
    this.paymentMethod,
  });

  @override
  List<Object?> get props => [patientId, paymentId, status, paymentMethod];
}

import 'package:equatable/equatable.dart';
import '../../domain/models/patient.dart';

abstract class AnamnesisEvent extends Equatable {
  const AnamnesisEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnamnesis extends AnamnesisEvent {
  final String patientId;
  const LoadAnamnesis(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

class SaveAnamnesis extends AnamnesisEvent {
  final String patientId;
  final Anamnesis anamnesis;

  const SaveAnamnesis({required this.patientId, required this.anamnesis});

  @override
  List<Object?> get props => [patientId, anamnesis];
}

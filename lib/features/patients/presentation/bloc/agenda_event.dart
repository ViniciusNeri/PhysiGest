import 'package:equatable/equatable.dart';
import 'package:physigest/features/patients/domain/models/appointment.dart';

abstract class AgendaEvent extends Equatable {
  const AgendaEvent();
  @override
  List<Object?> get props => [];
}

class LoadAgenda extends AgendaEvent {
  final String patientId;
  const LoadAgenda(this.patientId);
  @override
  List<Object?> get props => [patientId];
}

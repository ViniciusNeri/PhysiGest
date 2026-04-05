import 'package:equatable/equatable.dart';
import 'package:physigest/features/patients/domain/models/appointment.dart';

enum AgendaStatus { initial, loading, success, failure }

class AgendaState extends Equatable {
  final AgendaStatus status;
  final List<Appointment> appointments;
  final String? errorMessage;

  const AgendaState({
    this.status = AgendaStatus.initial,
    this.appointments = const [],
    this.errorMessage,
  });

  AgendaState copyWith({
    AgendaStatus? status,
    List<Appointment>? appointments,
    String? errorMessage,
  }) {
    return AgendaState(
      status: status ?? this.status,
      appointments: appointments ?? this.appointments,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, appointments, errorMessage];
}

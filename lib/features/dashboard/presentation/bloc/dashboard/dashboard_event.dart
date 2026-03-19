import 'package:equatable/equatable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {
  const LoadDashboardData();
}

class UpdateDashboardAppointment extends DashboardEvent {
  final Appointment appointment;

  const UpdateDashboardAppointment(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

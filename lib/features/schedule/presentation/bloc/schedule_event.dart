import 'package:equatable/equatable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';
import 'package:physigest/features/schedule/presentation/bloc/schedule_state.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

class LoadSchedule extends ScheduleEvent {}

class UpdateAppointment extends ScheduleEvent {
  final Appointment appointment;
  const UpdateAppointment(this.appointment);
}

class SelectDate extends ScheduleEvent {
  final DateTime selectedDate;

  const SelectDate(this.selectedDate);

  @override
  List<Object?> get props => [selectedDate];
}

class ChangeViewMode extends ScheduleEvent {
  final ScheduleViewMode viewMode;

  const ChangeViewMode(this.viewMode);

  @override
  List<Object?> get props => [viewMode];
}

class AddAppointment extends ScheduleEvent {
  final Appointment appointment;

  const AddAppointment(this.appointment);

  @override
  List<Object?> get props => [appointment];
}
class DeleteAppointment extends ScheduleEvent {
  final String id;

  const DeleteAppointment(this.id);

  @override
  List<Object?> get props => [id];
}

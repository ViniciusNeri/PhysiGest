import 'package:equatable/equatable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

class LoadSchedule extends ScheduleEvent {}

class UpdateAppointment extends ScheduleEvent {
  final Appointment appointment;
  UpdateAppointment(this.appointment);
}

class SelectDate extends ScheduleEvent {
  final DateTime selectedDate;

  const SelectDate(this.selectedDate);

  @override
  List<Object?> get props => [selectedDate];
}

class AddAppointment extends ScheduleEvent {
  final Appointment appointment;

  const AddAppointment(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

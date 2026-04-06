import 'package:equatable/equatable.dart';

abstract class PatientBookingEvent extends Equatable {
  const PatientBookingEvent();

  @override
  List<Object?> get props => [];
}

class LoadBookingData extends PatientBookingEvent {
  final String userId;
  const LoadBookingData(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SelectBookingDate extends PatientBookingEvent {
  final DateTime date;
  const SelectBookingDate(this.date);

  @override
  List<Object?> get props => [date];
}

class SelectBookingSlot extends PatientBookingEvent {
  final DateTime slot;
  const SelectBookingSlot(this.slot);

  @override
  List<Object?> get props => [slot];
}

class ConfirmBooking extends PatientBookingEvent {
  final String pin;
  const ConfirmBooking({required this.pin});

  @override
  List<Object?> get props => [pin];
}

class ChangeBookingMonth extends PatientBookingEvent {
  final int month;
  final int year;

  const ChangeBookingMonth({required this.month, required this.year});

  @override
  List<Object?> get props => [month, year];
}

class SelectBookingCategory extends PatientBookingEvent {
  final String categoryId;
  const SelectBookingCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

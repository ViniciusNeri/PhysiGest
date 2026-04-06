import 'package:equatable/equatable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';

class BirthdayEntry extends Equatable {
  final String patientId;
  final String name;
  final String birthDate;
  final int day;

  const BirthdayEntry({
    required this.patientId,
    required this.name,
    required this.birthDate,
    required this.day,
  });

  @override
  List<Object?> get props => [patientId, name, birthDate, day];
}

class PendingPaymentEntry extends Equatable {
  final String patientId;
  final String patientName;
  final double amount;
  final String date;
  final String? dueDate;

  const PendingPaymentEntry({
    required this.patientId,
    required this.patientName,
    required this.amount,
    required this.date,
    this.dueDate,
  });

  @override
  List<Object?> get props => [patientId, patientName, amount, date, dueDate];
}

class DashboardSummary extends Equatable {
  final int weeklyAppointments;
  final double monthlyIncome;
  final int activePayments;
  final List<Appointment> todaysAppointments;
  final Appointment? nextAppointment;
  final List<BirthdayEntry> birthdayList;
  final List<PendingPaymentEntry> pendingPayments;
  final List<Appointment> overdueAppointments;
  final Map<int, int> occupancyGraph;

  const DashboardSummary({
    required this.weeklyAppointments,
    required this.monthlyIncome,
    required this.activePayments,
    required this.todaysAppointments,
    this.nextAppointment,
    this.birthdayList = const [],
    this.pendingPayments = const [],
    this.overdueAppointments = const [],
    this.occupancyGraph = const {},
  });

  @override
  List<Object?> get props => [
        weeklyAppointments,
        monthlyIncome,
        activePayments,
        todaysAppointments,
        nextAppointment,
        birthdayList,
        pendingPayments,
        overdueAppointments,
        occupancyGraph,
      ];
}

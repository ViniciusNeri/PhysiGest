import 'package:equatable/equatable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';

class DashboardSummary extends Equatable {
  final int weeklyAppointments;
  final double monthlyIncome;
  final int activePayments;
  final List<Appointment> todaysAppointments;
  final Appointment? nextAppointment;

  const DashboardSummary({
    required this.weeklyAppointments,
    required this.monthlyIncome,
    required this.activePayments,
    required this.todaysAppointments,
    this.nextAppointment,
  });

  @override
  List<Object?> get props => [
        weeklyAppointments,
        monthlyIncome,
        activePayments,
        todaysAppointments,
        nextAppointment,
      ];
}

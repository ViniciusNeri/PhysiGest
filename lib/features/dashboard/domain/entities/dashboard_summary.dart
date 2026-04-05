import 'package:equatable/equatable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';

class DashboardSummary extends Equatable {
  final int weeklyAppointments;
  final double monthlyIncome;
  final int activePayments;
  final List<Appointment> todaysAppointments;
  final Appointment? nextAppointment;

  final List<Appointment> pastPendingAppointments;
  final List<Map<String, dynamic>> monthlyBirthdays;
  final Map<int, int> occupancyStats;

  const DashboardSummary({
    required this.weeklyAppointments,
    required this.monthlyIncome,
    required this.activePayments,
    required this.todaysAppointments,
    this.pastPendingAppointments = const [],
    this.monthlyBirthdays = const [],
    this.occupancyStats = const {},
    this.nextAppointment,
  });

  @override
  List<Object?> get props => [
        weeklyAppointments,
        monthlyIncome,
        activePayments,
        todaysAppointments,
        pastPendingAppointments,
        monthlyBirthdays,
        occupancyStats,
        nextAppointment,
      ];
}

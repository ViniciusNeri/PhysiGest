import 'package:equatable/equatable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final int weeklyAppointments;
  final double monthlyIncome;
  final int activePayments;
  final List<Appointment> todaysAppointments;
  final List<Appointment> pastPendingAppointments;
  final List<Map<String, dynamic>> monthlyBirthdays;
  final Map<int, int> occupancyStats;
  final Appointment? nextAppointment;
  final String? errorMessage;
  final String? successMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.weeklyAppointments = 0,
    this.monthlyIncome = 0.0,
    this.activePayments = 0,
    this.todaysAppointments = const [],
    this.pastPendingAppointments = const [],
    this.monthlyBirthdays = const [],
    this.occupancyStats = const {},
    this.nextAppointment,
    this.errorMessage,
    this.successMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    int? weeklyAppointments,
    double? monthlyIncome,
    int? activePayments,
    List<Appointment>? todaysAppointments,
    List<Appointment>? pastPendingAppointments,
    List<Map<String, dynamic>>? monthlyBirthdays,
    Map<int, int>? occupancyStats,
    Appointment? nextAppointment,
    String? errorMessage,
    String? successMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      weeklyAppointments: weeklyAppointments ?? this.weeklyAppointments,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      activePayments: activePayments ?? this.activePayments,
      todaysAppointments: todaysAppointments ?? this.todaysAppointments,
      pastPendingAppointments:
          pastPendingAppointments ?? this.pastPendingAppointments,
      monthlyBirthdays: monthlyBirthdays ?? this.monthlyBirthdays,
      occupancyStats: occupancyStats ?? this.occupancyStats,
      nextAppointment: nextAppointment ?? this.nextAppointment,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        weeklyAppointments,
        monthlyIncome,
        activePayments,
        todaysAppointments,
        pastPendingAppointments,
        monthlyBirthdays,
        occupancyStats,
        nextAppointment,
        errorMessage,
        successMessage,
      ];
}

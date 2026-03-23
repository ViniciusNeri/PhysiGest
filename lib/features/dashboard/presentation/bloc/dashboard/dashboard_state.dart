import 'package:equatable/equatable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final int weeklyAppointments;
  final double monthlyIncome;
  final int activePayments;
  final List<Appointment> todaysAppointments;
  final Appointment? nextAppointment;
  final Map<DateTime, List<String>> agendamentosSemana;

  const DashboardLoaded({
    required this.weeklyAppointments,
    required this.monthlyIncome,
    required this.activePayments,
    required this.todaysAppointments,
    this.nextAppointment,
    required this.agendamentosSemana,
  });

  DashboardLoaded copyWith({
    int? weeklyAppointments,
    double? monthlyIncome,
    int? activePayments,
    List<Appointment>? todaysAppointments,
    Appointment? nextAppointment,
    Map<DateTime, List<String>>? agendamentosSemana,
  }) {
    return DashboardLoaded(
      weeklyAppointments: weeklyAppointments ?? this.weeklyAppointments,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      activePayments: activePayments ?? this.activePayments,
      todaysAppointments: todaysAppointments ?? this.todaysAppointments,
      nextAppointment: nextAppointment ?? this.nextAppointment,
      agendamentosSemana: agendamentosSemana ?? this.agendamentosSemana,
    );
  }

  @override
  List<Object?> get props => [
        weeklyAppointments,
        monthlyIncome,
        activePayments,
        todaysAppointments,
        nextAppointment,
        agendamentosSemana,
      ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';
import 'package:physigest/features/dashboard/domain/entities/dashboard_summary.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final int weeklyAppointments;
  final double monthlyIncome;
  final int activePayments;
  final List<Appointment> todaysAppointments;
  final Appointment? nextAppointment;
  final List<BirthdayEntry> birthdayList;
  final List<PendingPaymentEntry> pendingPayments;
  final List<Appointment> overdueAppointments;
  final Map<int, int> occupancyGraph;
  final String? errorMessage;
  final String? successMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.weeklyAppointments = 0,
    this.monthlyIncome = 0.0,
    this.activePayments = 0,
    this.todaysAppointments = const [],
    this.nextAppointment,
    this.birthdayList = const [],
    this.pendingPayments = const [],
    this.overdueAppointments = const [],
    this.occupancyGraph = const {},
    this.errorMessage,
    this.successMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    int? weeklyAppointments,
    double? monthlyIncome,
    int? activePayments,
    List<Appointment>? todaysAppointments,
    Appointment? nextAppointment,
    List<BirthdayEntry>? birthdayList,
    List<PendingPaymentEntry>? pendingPayments,
    List<Appointment>? overdueAppointments,
    Map<int, int>? occupancyGraph,
    String? errorMessage,
    String? successMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      weeklyAppointments: weeklyAppointments ?? this.weeklyAppointments,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      activePayments: activePayments ?? this.activePayments,
      todaysAppointments: todaysAppointments ?? this.todaysAppointments,
      nextAppointment: nextAppointment ?? this.nextAppointment,
      birthdayList: birthdayList ?? this.birthdayList,
      pendingPayments: pendingPayments ?? this.pendingPayments,
      overdueAppointments: overdueAppointments ?? this.overdueAppointments,
      occupancyGraph: occupancyGraph ?? this.occupancyGraph,
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
        nextAppointment,
        birthdayList,
        pendingPayments,
        overdueAppointments,
        occupancyGraph,
        errorMessage,
        successMessage,
      ];
}

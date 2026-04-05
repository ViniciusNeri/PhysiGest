import 'package:equatable/equatable.dart';

class DashboardPreferences extends Equatable {
  final String id;
  final String dashboardTheme;
  final bool showWeeklyAppointments;
  final bool showMonthlyIncome;
  final bool showActivePayments;
  final bool showNextAppointment;
  final String categoryControlMode;

  final bool showPastPending;
  final bool showBirthdays;
  final bool showOccupancyChart;

  const DashboardPreferences({
    this.id = '',
    this.dashboardTheme = 'light',
    this.showWeeklyAppointments = true,
    this.showMonthlyIncome = true,
    this.showActivePayments = true,
    this.showNextAppointment = true,
    this.showPastPending = true,
    this.showBirthdays = true,
    this.showOccupancyChart = true,
    this.categoryControlMode = 'none',
  });

  DashboardPreferences copyWith({
    String? id,
    String? dashboardTheme,
    bool? showWeeklyAppointments,
    bool? showMonthlyIncome,
    bool? showActivePayments,
    bool? showNextAppointment,
    bool? showPastPending,
    bool? showBirthdays,
    bool? showOccupancyChart,
    String? categoryControlMode,
  }) {
    return DashboardPreferences(
      id: id ?? this.id,
      dashboardTheme: dashboardTheme ?? this.dashboardTheme,
      showWeeklyAppointments:
          showWeeklyAppointments ?? this.showWeeklyAppointments,
      showMonthlyIncome: showMonthlyIncome ?? this.showMonthlyIncome,
      showActivePayments: showActivePayments ?? this.showActivePayments,
      showNextAppointment: showNextAppointment ?? this.showNextAppointment,
      showPastPending: showPastPending ?? this.showPastPending,
      showBirthdays: showBirthdays ?? this.showBirthdays,
      showOccupancyChart: showOccupancyChart ?? this.showOccupancyChart,
      categoryControlMode: categoryControlMode ?? this.categoryControlMode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        dashboardTheme,
        showWeeklyAppointments,
        showMonthlyIncome,
        showActivePayments,
        showNextAppointment,
        showPastPending,
        showBirthdays,
        showOccupancyChart,
        categoryControlMode,
      ];
}

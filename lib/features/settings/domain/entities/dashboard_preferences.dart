import 'package:equatable/equatable.dart';

class DashboardPreferences extends Equatable {
  final String dashboardTheme;
  final bool showWeeklyAppointments;
  final bool showMonthlyIncome;
  final bool showActivePayments;
  final bool showNextAppointment;
  final String categoryControlMode;

  const DashboardPreferences({
    this.dashboardTheme = 'light',
    this.showWeeklyAppointments = true,
    this.showMonthlyIncome = true,
    this.showActivePayments = true,
    this.showNextAppointment = true,
    this.categoryControlMode = 'none',
  });

  DashboardPreferences copyWith({
    String? dashboardTheme,
    bool? showWeeklyAppointments,
    bool? showMonthlyIncome,
    bool? showActivePayments,
    bool? showNextAppointment,
    String? categoryControlMode,
  }) {
    return DashboardPreferences(
      dashboardTheme: dashboardTheme ?? this.dashboardTheme,
      showWeeklyAppointments:
          showWeeklyAppointments ?? this.showWeeklyAppointments,
      showMonthlyIncome: showMonthlyIncome ?? this.showMonthlyIncome,
      showActivePayments: showActivePayments ?? this.showActivePayments,
      showNextAppointment: showNextAppointment ?? this.showNextAppointment,
      categoryControlMode: categoryControlMode ?? this.categoryControlMode,
    );
  }

  @override
  List<Object?> get props => [
        dashboardTheme,
        showWeeklyAppointments,
        showMonthlyIncome,
        showActivePayments,
        showNextAppointment,
        categoryControlMode,
      ];
}

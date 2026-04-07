import 'package:equatable/equatable.dart';

class DashboardPreferences extends Equatable {
  final String id;
  final String userId;
  final String dashboardTheme;
  final bool showWeeklyAppointments;
  final bool showMonthlyIncome;
  final bool showActivePayments;
  final bool showNextAppointment;
  final bool showPendingPayments;
  final bool showBirthdays;
  final bool showOccupancyGraph;
  final bool showOverdueAppointments;
  final String categoryControlMode;
  final String? defaultCategoryId;
  final String? defaultPaymentMethodId;
  final List<int> workingDays;

  const DashboardPreferences({
    this.id = '',
    this.userId = '',
    this.dashboardTheme = 'light',
    this.showWeeklyAppointments = true,
    this.showMonthlyIncome = true,
    this.showActivePayments = true,
    this.showNextAppointment = true,
    this.showPendingPayments = true,
    this.showBirthdays = true,
    this.showOccupancyGraph = true,
    this.showOverdueAppointments = true,
    this.categoryControlMode = 'none',
    this.defaultCategoryId,
    this.defaultPaymentMethodId,
    this.workingDays = const [1, 2, 3, 4, 5], // Padrão Seg-Sex
  });

  DashboardPreferences copyWith({
    String? id,
    String? userId,
    String? dashboardTheme,
    bool? showWeeklyAppointments,
    bool? showMonthlyIncome,
    bool? showActivePayments,
    bool? showNextAppointment,
    bool? showPendingPayments,
    bool? showBirthdays,
    bool? showOccupancyGraph,
    bool? showOverdueAppointments,
    String? categoryControlMode,
    String? defaultCategoryId,
    String? defaultPaymentMethodId,
    List<int>? workingDays,
  }) {
    return DashboardPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dashboardTheme: dashboardTheme ?? this.dashboardTheme,
      showWeeklyAppointments:
          showWeeklyAppointments ?? this.showWeeklyAppointments,
      showMonthlyIncome: showMonthlyIncome ?? this.showMonthlyIncome,
      showActivePayments: showActivePayments ?? this.showActivePayments,
      showNextAppointment: showNextAppointment ?? this.showNextAppointment,
      showPendingPayments: showPendingPayments ?? this.showPendingPayments,
      showBirthdays: showBirthdays ?? this.showBirthdays,
      showOccupancyGraph: showOccupancyGraph ?? this.showOccupancyGraph,
      showOverdueAppointments:
          showOverdueAppointments ?? this.showOverdueAppointments,
      categoryControlMode: categoryControlMode ?? this.categoryControlMode,
      defaultCategoryId: defaultCategoryId ?? this.defaultCategoryId,
      defaultPaymentMethodId:
          defaultPaymentMethodId ?? this.defaultPaymentMethodId,
      workingDays: workingDays ?? this.workingDays,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        dashboardTheme,
        showWeeklyAppointments,
        showMonthlyIncome,
        showActivePayments,
        showNextAppointment,
        showPendingPayments,
        showBirthdays,
        showOccupancyGraph,
        showOverdueAppointments,
        categoryControlMode,
        defaultCategoryId,
        defaultPaymentMethodId,
        workingDays,
      ];
}

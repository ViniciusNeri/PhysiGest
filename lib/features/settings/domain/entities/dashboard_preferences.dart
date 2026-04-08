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
  final List<int> operatingDays;
  final String startTime;
  final String endTime;
  final String lunchStart;
  final String lunchEnd;
  final String timezone;
  final DateTime? updatedAt;
  final DateTime? createdAt;

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
    this.operatingDays = const [1, 2, 3, 4, 5], // Padrão Seg-Sex (Seg=1, ..., Sex=5)
    this.startTime = '08:00',
    this.endTime = '18:00',
    this.lunchStart = '12:00',
    this.lunchEnd = '13:00',
    this.timezone = 'America/Sao_Paulo',
    this.updatedAt,
    this.createdAt,
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
    List<int>? operatingDays,
    String? startTime,
    String? endTime,
    String? lunchStart,
    String? lunchEnd,
    String? timezone,
    DateTime? updatedAt,
    DateTime? createdAt,
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
      operatingDays: operatingDays ?? this.operatingDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      lunchStart: lunchStart ?? this.lunchStart,
      lunchEnd: lunchEnd ?? this.lunchEnd,
      timezone: timezone ?? this.timezone,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
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
        operatingDays,
        startTime,
        endTime,
        lunchStart,
        lunchEnd,
        timezone,
        updatedAt,
        createdAt,
      ];
}

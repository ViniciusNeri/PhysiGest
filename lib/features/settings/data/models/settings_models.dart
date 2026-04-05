import 'package:physigest/features/settings/domain/entities/attendance_category.dart';
import 'package:physigest/features/settings/domain/entities/payment_method.dart';
import 'package:physigest/features/settings/domain/entities/dashboard_preferences.dart';

class AttendanceCategoryModel extends AttendanceCategory {
  const AttendanceCategoryModel({
    required super.id,
    required super.name,
    super.isActive = true,
  });

  factory AttendanceCategoryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'isActive': isActive};
  }
}

class PaymentMethodModel extends PaymentMethod {
  const PaymentMethodModel({
    required super.id,
    required super.name,
    super.isActive = true,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'isActive': isActive};
  }
}

class DashboardPreferencesModel extends DashboardPreferences {
  const DashboardPreferencesModel({
    super.id = '',
    super.dashboardTheme = 'light',
    super.showWeeklyAppointments = true,
    super.showMonthlyIncome = true,
    super.showActivePayments = true,
    super.showNextAppointment = true,
    super.showPastPending = true,
    super.showBirthdays = true,
    super.showOccupancyChart = true,
    super.categoryControlMode = 'none',
  });

  factory DashboardPreferencesModel.fromJson(Map<String, dynamic> json) {
    return DashboardPreferencesModel(
      id: (json['id'] ?? json['_id'] ?? json['codigo'])?.toString() ?? '',
      dashboardTheme: json['dashboardTheme'] as String? ?? 'light',
      showWeeklyAppointments: json['showWeeklyAppointments'] as bool? ?? true,
      showMonthlyIncome: json['showMonthlyIncome'] as bool? ?? true,
      showActivePayments: json['showActivePayments'] as bool? ?? true,
      showNextAppointment: json['showNextAppointment'] as bool? ?? true,
      showPastPending: json['showPastPending'] as bool? ?? true,
      showBirthdays: json['showBirthdays'] as bool? ?? true,
      showOccupancyChart: json['showOccupancyChart'] as bool? ?? true,
      categoryControlMode: json['categoryControlMode'] as String? ?? 'none',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'dashboardTheme': dashboardTheme,
      'showWeeklyAppointments': showWeeklyAppointments,
      'showMonthlyIncome': showMonthlyIncome,
      'showActivePayments': showActivePayments,
      'showNextAppointment': showNextAppointment,
      'showPastPending': showPastPending,
      'showBirthdays': showBirthdays,
      'showOccupancyChart': showOccupancyChart,
      'categoryControlMode': categoryControlMode,
    };
  }
}

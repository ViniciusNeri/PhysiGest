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
    super.dashboardTheme = 'light',
    super.showWeeklyAppointments = true,
    super.showMonthlyIncome = true,
    super.showActivePayments = true,
    super.showNextAppointment = true,
    super.categoryControlMode = 'none',
  });

  factory DashboardPreferencesModel.fromJson(Map<String, dynamic> json) {
    return DashboardPreferencesModel(
      dashboardTheme: json['dashboardTheme'] as String? ?? 'light',
      showWeeklyAppointments: json['showWeeklyAppointments'] as bool? ?? true,
      showMonthlyIncome: json['showMonthlyIncome'] as bool? ?? true,
      showActivePayments: json['showActivePayments'] as bool? ?? true,
      showNextAppointment: json['showNextAppointment'] as bool? ?? true,
      categoryControlMode: json['categoryControlMode'] as String? ?? 'none',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dashboardTheme': dashboardTheme,
      'showWeeklyAppointments': showWeeklyAppointments,
      'showMonthlyIncome': showMonthlyIncome,
      'showActivePayments': showActivePayments,
      'showNextAppointment': showNextAppointment,
      'categoryControlMode': categoryControlMode,
    };
  }
}

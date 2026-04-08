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
    super.userId = '',
    super.dashboardTheme = 'light',
    super.showWeeklyAppointments = true,
    super.showMonthlyIncome = true,
    super.showActivePayments = true,
    super.showNextAppointment = true,
    super.showPendingPayments = true,
    super.showBirthdays = true,
    super.showOccupancyGraph = true,
    super.showOverdueAppointments = true,
    super.categoryControlMode = 'none',
    super.defaultCategoryId,
    super.defaultPaymentMethodId,
    super.operatingDays = const [1, 2, 3, 4, 5],
    super.startTime = '08:00',
    super.endTime = '18:00',
    super.lunchStart = '12:00',
    super.lunchEnd = '13:00',
    super.timezone = 'America/Sao_Paulo',
    super.updatedAt,
    super.createdAt,
  });

  factory DashboardPreferencesModel.fromJson(Map<String, dynamic> json) {
    final businessHours = json['businessHours'] as Map<String, dynamic>? ?? {};

    return DashboardPreferencesModel(
      id: (json['id'] ?? json['_id'] ?? json['codigo'])?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      dashboardTheme: json['dashboardTheme'] as String? ?? 'light',
      showWeeklyAppointments: json['showWeeklyAppointments'] as bool? ?? true,
      showMonthlyIncome: json['showMonthlyIncome'] as bool? ?? true,
      showActivePayments: json['showActivePayments'] as bool? ?? true,
      showNextAppointment: json['showNextAppointment'] as bool? ?? true,
      showPendingPayments: json['showPendingPayments'] as bool? ?? true,
      showBirthdays: json['showBirthdays'] as bool? ?? true,
      showOccupancyGraph: json['showOccupancyGraph'] as bool? ?? true,
      showOverdueAppointments: json['showOverdueAppointments'] as bool? ?? true,
      categoryControlMode: json['categoryControlMode'] as String? ?? 'none',
      defaultCategoryId: json['defaultCategoryId']?.toString(),
      defaultPaymentMethodId: json['defaultPaymentMethodId']?.toString(),
      operatingDays: json['operatingDays'] is List
          ? (json['operatingDays'] as List).map((e) => int.parse(e.toString())).toList()
          : (json['workingDays'] is List // Fallback for transition
              ? (json['workingDays'] as List).map((e) => int.parse(e.toString())).toList()
              : const [1, 2, 3, 4, 5]),
      startTime: businessHours['startTime']?.toString() ?? '08:00',
      endTime: businessHours['endTime']?.toString() ?? '18:00',
      lunchStart: businessHours['lunchStart']?.toString() ?? '12:00',
      lunchEnd: businessHours['lunchEnd']?.toString() ?? '13:00',
      timezone: json['timezone']?.toString() ?? 'America/Sao_Paulo',
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'].toString().split('Z')[0]) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString().split('Z')[0]) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'dashboardTheme': dashboardTheme,
      'showWeeklyAppointments': showWeeklyAppointments,
      'showMonthlyIncome': showMonthlyIncome,
      'showActivePayments': showActivePayments,
      'showNextAppointment': showNextAppointment,
      'showPendingPayments': showPendingPayments,
      'showBirthdays': showBirthdays,
      'showOccupancyGraph': showOccupancyGraph,
      'showOverdueAppointments': showOverdueAppointments,
      'categoryControlMode': categoryControlMode,
      'defaultCategoryId': defaultCategoryId,
      'defaultPaymentMethodId': defaultPaymentMethodId,
      'operatingDays': operatingDays,
      'businessHours': {
        'startTime': startTime,
        'endTime': endTime,
        'lunchStart': lunchStart,
        'lunchEnd': lunchEnd,
      },
      'timezone': timezone,
      'updatedAt': updatedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory DashboardPreferencesModel.fromEntity(DashboardPreferences entity) {
    return DashboardPreferencesModel(
      id: entity.id,
      userId: entity.userId,
      dashboardTheme: entity.dashboardTheme,
      showWeeklyAppointments: entity.showWeeklyAppointments,
      showMonthlyIncome: entity.showMonthlyIncome,
      showActivePayments: entity.showActivePayments,
      showNextAppointment: entity.showNextAppointment,
      showPendingPayments: entity.showPendingPayments,
      showBirthdays: entity.showBirthdays,
      showOccupancyGraph: entity.showOccupancyGraph,
      showOverdueAppointments: entity.showOverdueAppointments,
      categoryControlMode: entity.categoryControlMode,
      defaultCategoryId: entity.defaultCategoryId,
      defaultPaymentMethodId: entity.defaultPaymentMethodId,
      operatingDays: entity.operatingDays,
      startTime: entity.startTime,
      endTime: entity.endTime,
      lunchStart: entity.lunchStart,
      lunchEnd: entity.lunchEnd,
      timezone: entity.timezone,
      updatedAt: entity.updatedAt,
      createdAt: entity.createdAt,
    );
  }
}

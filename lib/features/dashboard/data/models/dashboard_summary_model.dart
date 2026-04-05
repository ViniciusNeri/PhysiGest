import 'package:physigest/features/schedule/domain/models/appointment.dart';
import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.weeklyAppointments,
    required super.monthlyIncome,
    required super.activePayments,
    required super.todaysAppointments,
    super.pastPendingAppointments = const [],
    super.monthlyBirthdays = const [],
    super.occupancyStats = const {},
    super.nextAppointment,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      weeklyAppointments: json['weeklyAppointments'] as int? ?? 0,
      monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 0.0,
      activePayments: json['activePayments'] as int? ?? 0,
      todaysAppointments: (json['todaysAppointments'] as List<dynamic>?)
              ?.map((a) => _mapAppointment(a))
              .toList() ??
          [],
      pastPendingAppointments: (json['pastPendingAppointments'] as List<dynamic>?)
              ?.map((a) => _mapAppointment(a))
              .toList() ??
          [],
      monthlyBirthdays: (json['monthlyBirthdays'] as List<dynamic>?)
              ?.map((b) => b as Map<String, dynamic>)
              .toList() ??
          [],
      occupancyStats: (json['occupancyStats'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(int.parse(k), v as int)) ??
          {},
      nextAppointment: json['nextAppointment'] != null
          ? _mapAppointment(json['nextAppointment'])
          : null,
    );
  }

  static Appointment _mapAppointment(Map<String, dynamic> json) {
    String rawStatus = (json['status'] ?? 'scheduled').toString().toLowerCase();
    String normalizedStatus;
    switch (rawStatus) {
      case 'agendado':
        normalizedStatus = 'scheduled';
        break;
      case 'realizado':
        normalizedStatus = 'completed';
        break;
      case 'cancelado':
        normalizedStatus = 'cancelled';
        break;
      case 'falta':
        normalizedStatus = 'no_show';
        break;
      default:
        normalizedStatus = rawStatus;
    }

    return Appointment(
      id: json['id']?.toString() ?? '',
      patientName: json['patientName'] ?? 'Paciente',
      patientId: json['patientId']?.toString(),
      userId: json['userId']?.toString(),
      description: json['description'] ?? '',
      categoryId: json['categoryId']?.toString(),
      categoryName: json['categoryName']?.toString(),
      startDate: (DateTime.tryParse(json['date'] ?? '') ?? DateTime.now()).toLocal(),
      endDate: (DateTime.tryParse(json['date'] ?? '') ?? DateTime.now()).toLocal().add(const Duration(hours: 1)),
      status: normalizedStatus,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weeklyAppointments': weeklyAppointments,
      'monthlyIncome': monthlyIncome,
      'activePayments': activePayments,
    };
  }
}

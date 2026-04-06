import 'package:physigest/features/schedule/domain/models/appointment.dart';
import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.weeklyAppointments,
    required super.monthlyIncome,
    required super.activePayments,
    required super.todaysAppointments,
    super.nextAppointment,
    super.birthdayList = const [],
    super.pendingPayments = const [],
    super.overdueAppointments = const [],
    super.occupancyGraph = const {},
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      weeklyAppointments: json['weeklyAppointments'] as int? ?? 0,
      monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 0.0,
      activePayments: json['activePayments'] as int? ?? 0,
      todaysAppointments: (json['todaysAppointments'] as List<dynamic>?)
              ?.map((a) => _mapAppointment(a as Map<String, dynamic>))
              .toList() ??
          [],
      nextAppointment: json['nextAppointment'] != null
          ? _mapAppointment(json['nextAppointment'] as Map<String, dynamic>)
          : null,
      birthdayList: (json['birthdayList'] as List<dynamic>?)
              ?.map((b) => _mapBirthday(b as Map<String, dynamic>))
              .toList() ??
          [],
      pendingPayments: (json['pendingPayments'] as List<dynamic>?)
              ?.map((p) => _mapPendingPayment(p as Map<String, dynamic>))
              .toList() ??
          [],
      overdueAppointments: (json['overdueAppointments'] as List<dynamic>?)
              ?.map((a) => _mapAppointment(a as Map<String, dynamic>))
              .toList() ??
          [],
      occupancyGraph: (json['occupancyGraph'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(int.tryParse(k) ?? 0, (v as num).toInt())) ??
          {},
    );
  }

  static Appointment _mapAppointment(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? 'scheduled').toString().toLowerCase();
    final normalizedStatus = _normalizeStatus(rawStatus);

    return Appointment(
      id: json['id']?.toString() ?? '',
      patientName: json['patientName'] ?? 'Paciente',
      patientId: json['patientId']?.toString(),
      userId: json['userId']?.toString(),
      description: json['description'] ?? '',
      categoryId: json['categoryId']?.toString(),
      categoryName: json['categoryName']?.toString(),
      startDate: (DateTime.tryParse(json['date'] ?? '') ?? DateTime.now()).toLocal(),
      endDate: (DateTime.tryParse(json['date'] ?? '') ?? DateTime.now())
          .toLocal()
          .add(const Duration(hours: 1)),
      status: normalizedStatus,
      notes: json['notes'],
    );
  }

  static BirthdayEntry _mapBirthday(Map<String, dynamic> json) {
    return BirthdayEntry(
      patientId: json['patientId']?.toString() ?? '',
      name: json['name'] ?? '',
      birthDate: json['birthDate'] ?? '',
      day: json['day'] as int? ?? 0,
    );
  }

  static PendingPaymentEntry _mapPendingPayment(Map<String, dynamic> json) {
    return PendingPaymentEntry(
      patientId: json['patientId']?.toString() ?? '',
      patientName: json['patientName'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] ?? '',
      dueDate: json['dueDate']?.toString(),
    );
  }

  static String _normalizeStatus(String raw) {
    switch (raw) {
      case 'agendado':
        return 'scheduled';
      case 'realizado':
        return 'completed';
      case 'cancelado':
        return 'cancelled';
      case 'falta':
        return 'no_show';
      default:
        return raw;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'weeklyAppointments': weeklyAppointments,
      'monthlyIncome': monthlyIncome,
      'activePayments': activePayments,
    };
  }
}

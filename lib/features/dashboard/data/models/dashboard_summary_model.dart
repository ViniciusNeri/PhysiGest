import 'package:physigest/features/schedule/domain/models/appointment.dart';
import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.weeklyAppointments,
    required super.monthlyIncome,
    required super.activePayments,
    required super.todaysAppointments,
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
      nextAppointment: json['nextAppointment'] != null
          ? _mapAppointment(json['nextAppointment'])
          : null,
    );
  }

  static Appointment _mapAppointment(Map<String, dynamic> json) {
    return Appointment(
      id: json['id']?.toString() ?? '',
      patientName: json['patientName'] ?? 'Paciente', // Default if missing
      patientId: json['patientId']?.toString(),
      description: json['description'] ?? '',
      type: json['description'] ?? 'Consulta', // Map description to type
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      time: json['time'] ?? '00:00',
      endTime: '00:00', // Default
      status: 'agendado',
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

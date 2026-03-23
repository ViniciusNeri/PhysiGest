import 'package:physigest/features/schedule/domain/models/appointment.dart';
import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.atendimentosHoje,
    required super.mensalidadesVencer,
    required super.atendimentosSemana,
    required super.fichasVencidas,
    required super.atendimentosHojeList,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final appointmentsJson = json['atendimentosHoje'] as List<dynamic>? ?? [];
    return DashboardSummaryModel(
      atendimentosHoje: json['totalAtendimentosHoje'] as int? ?? 0,
      mensalidadesVencer: json['mensalidadesVencer'] as int? ?? 0,
      atendimentosSemana: json['atendimentosSemana'] as int? ?? 0,
      fichasVencidas: json['fichasVencidas'] as int? ?? 0,
      atendimentosHojeList: appointmentsJson.map((a) => Appointment(
        id: a['id']?.toString() ?? '',
        patientName: a['patientName'] ?? '',
        type: a['type'] ?? '',
        date: DateTime.tryParse(a['date'] ?? '') ?? DateTime.now(),
        time: a['time'] ?? '00:00',
        endTime: a['endTime'] ?? '00:00',
        status: a['status'] ?? 'agendado',
      )).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAtendimentosHoje': atendimentosHoje,
      'mensalidadesVencer': mensalidadesVencer,
      'atendimentosSemana': atendimentosSemana,
      'fichasVencidas': fichasVencidas,
    };
  }
}

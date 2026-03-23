import 'package:equatable/equatable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';

class DashboardSummary extends Equatable {
  final int atendimentosHoje;
  final int mensalidadesVencer;
  final int atendimentosSemana;
  final int fichasVencidas;
  final List<Appointment> atendimentosHojeList;

  const DashboardSummary({
    required this.atendimentosHoje,
    required this.mensalidadesVencer,
    required this.atendimentosSemana,
    required this.fichasVencidas,
    required this.atendimentosHojeList,
  });

  @override
  List<Object?> get props => [
        atendimentosHoje,
        mensalidadesVencer,
        atendimentosSemana,
        fichasVencidas,
        atendimentosHojeList,
      ];
}

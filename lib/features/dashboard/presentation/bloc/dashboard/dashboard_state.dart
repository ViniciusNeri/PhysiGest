import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final int atendimentosHoje;
  final int mensalidadesVencer;
  final int atendimentosSemana;
  final int fichasVencidas;
  final Map<DateTime, List<String>> agendamentosSemana; // Simplificação para horário/detalhes

  const DashboardLoaded({
    required this.atendimentosHoje,
    required this.mensalidadesVencer,
    required this.atendimentosSemana,
    required this.fichasVencidas,
    required this.agendamentosSemana,
  });

  @override
  List<Object?> get props => [
        atendimentosHoje,
        mensalidadesVencer,
        atendimentosSemana,
        fichasVencidas,
        agendamentosSemana,
      ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';

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
  final Map<DateTime, List<String>> agendamentosSemana;
  final List<Appointment> atendimentosHojeList;

  const DashboardLoaded({
    required this.atendimentosHoje,
    required this.mensalidadesVencer,
    required this.atendimentosSemana,
    required this.fichasVencidas,
    required this.agendamentosSemana,
    required this.atendimentosHojeList,
  });

  DashboardLoaded copyWith({
    int? atendimentosHoje,
    int? mensalidadesVencer,
    int? atendimentosSemana,
    int? fichasVencidas,
    Map<DateTime, List<String>>? agendamentosSemana,
    List<Appointment>? atendimentosHojeList,
  }) {
    return DashboardLoaded(
      atendimentosHoje: atendimentosHoje ?? this.atendimentosHoje,
      mensalidadesVencer: mensalidadesVencer ?? this.mensalidadesVencer,
      atendimentosSemana: atendimentosSemana ?? this.atendimentosSemana,
      fichasVencidas: fichasVencidas ?? this.fichasVencidas,
      agendamentosSemana: agendamentosSemana ?? this.agendamentosSemana,
      atendimentosHojeList: atendimentosHojeList ?? this.atendimentosHojeList,
    );
  }

  @override
  List<Object?> get props => [
        atendimentosHoje,
        mensalidadesVencer,
        atendimentosSemana,
        fichasVencidas,
        agendamentosSemana,
        atendimentosHojeList,
      ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

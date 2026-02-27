import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import 'dashboard_event.dart';
import 'dashboard_state.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardLoading()) {
    on<LoadDashboardData>(_onLoadDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      // Simulando fetch de dados do backend
      await Future.delayed(const Duration(seconds: 1));
      
      final today = DateTime.now();
      
      emit(DashboardLoaded(
        atendimentosHoje: 8,
        mensalidadesVencer: 3,
        atendimentosSemana: 32,
        fichasVencidas: 5,
        agendamentosSemana: {
          DateTime(today.year, today.month, today.day, 9, 0): [
            'João Silva - 09:00 (Avaliação)',
          ],
          DateTime(today.year, today.month, today.day, 10, 30): [
            'Maria Souza - 10:30 (Pilates)',
          ],
          DateTime(today.year, today.month, today.day, 14, 0): [
            'Pedro Santos - 14:00 (Fisioterapia)',
          ],
        },
      ));
    } catch (e) {
      emit(DashboardError('Erro ao carregar dashboard: $e'));
    }
  }
}

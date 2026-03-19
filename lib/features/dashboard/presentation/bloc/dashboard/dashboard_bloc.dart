import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:physigest/features/schedule/domain/models/appointment.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(const DashboardLoading()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<UpdateDashboardAppointment>(_onUpdateDashboardAppointment);
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
        atendimentosHojeList: [
          Appointment(id: 'dash_1', patientName: 'Maria Silva', type: 'Fisioterapia', date: today, time: '09:00', endTime: '10:00', status: 'realizado'),
          Appointment(id: 'dash_2', patientName: 'Ricardo Alves', type: 'Pilates', date: today, time: '10:30', endTime: '11:30', status: 'agendado'),
          Appointment(id: 'dash_3', patientName: 'Carla Dias', type: 'Avaliação Inicial', date: today, time: '14:00', endTime: '15:00', status: 'agendado'),
        ]
      ));
    } catch (e) {
      emit(DashboardError('Erro ao carregar dashboard: $e'));
    }
  }

  void _onUpdateDashboardAppointment(UpdateDashboardAppointment event, Emitter<DashboardState> emit) {
    if (state is DashboardLoaded) {
      final loadedState = state as DashboardLoaded;
      
      final updatedList = loadedState.atendimentosHojeList.map((apt) {
        if (apt.id == event.appointment.id) {
          return event.appointment;
        }
        return apt;
      }).toList();

      emit(loadedState.copyWith(atendimentosHojeList: updatedList));
    }
  }
}

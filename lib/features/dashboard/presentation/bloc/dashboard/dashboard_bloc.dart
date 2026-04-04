import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import 'dashboard_event.dart';
import 'dashboard_state.dart';

import 'package:physigest/features/dashboard/domain/usecases/dashboard_usecases.dart';
import 'package:physigest/features/schedule/domain/usecases/schedule_usecases.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummaryUseCase _getSummaryUseCase;
  final UpdateAppointmentUseCase _updateAppointmentUseCase;

  DashboardBloc(
    this._getSummaryUseCase,
    this._updateAppointmentUseCase,
  ) : super(const DashboardLoading()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<UpdateDashboardAppointment>(_onUpdateDashboardAppointment);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      final summary = await _getSummaryUseCase();

      emit(
        DashboardLoaded(
          weeklyAppointments: summary.weeklyAppointments,
          monthlyIncome: summary.monthlyIncome,
          activePayments: summary.activePayments,
          todaysAppointments: summary.todaysAppointments,
          nextAppointment: summary.nextAppointment,
          agendamentosSemana: const {},
        ),
      );
    } catch (e) {
      emit(DashboardError('Erro ao carregar dashboard: $e'));
    }
  }

  Future<void> _onUpdateDashboardAppointment(
    UpdateDashboardAppointment event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      try {
        // 1. Persiste no Backend
        await _updateAppointmentUseCase(event.appointment);

        // 2. Atualiza localmente para feedback instantâneo (opcional, já que vamos recarregar)
        final loadedState = state as DashboardLoaded;
        final updatedList = loadedState.todaysAppointments.map((apt) {
          if (apt.id == event.appointment.id) {
            return event.appointment;
          }
          return apt;
        }).toList();

        emit(loadedState.copyWith(todaysAppointments: updatedList));

        // 3. Recarrega os dados do dashboard para atualizar métricas (faturamento, etc)
        add(const LoadDashboardData());
      } catch (e) {
        emit(DashboardError('Erro ao atualizar agendamento no dashboard: $e'));
      }
    }
  }
}

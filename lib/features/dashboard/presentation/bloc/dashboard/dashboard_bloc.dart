import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import 'dashboard_event.dart';
import 'dashboard_state.dart';

import 'package:physigest/features/dashboard/domain/usecases/dashboard_usecases.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummaryUseCase _getSummaryUseCase;

  DashboardBloc(this._getSummaryUseCase) : super(const DashboardLoading()) {
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

  void _onUpdateDashboardAppointment(
    UpdateDashboardAppointment event,
    Emitter<DashboardState> emit,
  ) {
    if (state is DashboardLoaded) {
      final loadedState = state as DashboardLoaded;

      final updatedList = loadedState.todaysAppointments.map((apt) {
        if (apt.id == event.appointment.id) {
          return event.appointment;
        }
        return apt;
      }).toList();

      emit(loadedState.copyWith(todaysAppointments: updatedList));
    }
  }
}

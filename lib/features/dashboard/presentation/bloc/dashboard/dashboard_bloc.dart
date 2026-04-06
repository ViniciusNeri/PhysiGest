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
  ) : super(const DashboardState()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<UpdateDashboardAppointment>(_onUpdateDashboardAppointment);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final summary = await _getSummaryUseCase();

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          weeklyAppointments: summary.weeklyAppointments,
          monthlyIncome: summary.monthlyIncome,
          activePayments: summary.activePayments,
          todaysAppointments: summary.todaysAppointments,
          nextAppointment: summary.nextAppointment,
          birthdayList: summary.birthdayList,
          pendingPayments: summary.pendingPayments,
          overdueAppointments: summary.overdueAppointments,
          occupancyGraph: summary.occupancyGraph,
          successMessage: null,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpdateDashboardAppointment(
    UpdateDashboardAppointment event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(
      status: DashboardStatus.loading,
      successMessage: null,
      errorMessage: null,
    ));
    try {
      await _updateAppointmentUseCase(event.appointment);

      final updatedList = state.todaysAppointments.map((apt) {
        if (apt.id == event.appointment.id) return event.appointment;
        return apt;
      }).toList();

      emit(state.copyWith(
        status: DashboardStatus.success,
        todaysAppointments: updatedList,
        successMessage: 'Atendimento atualizado com sucesso!',
      ));

      add(const LoadDashboardData());
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}

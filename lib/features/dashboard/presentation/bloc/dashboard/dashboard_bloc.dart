import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';

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
          pastPendingAppointments: summary.pastPendingAppointments.isNotEmpty
              ? summary.pastPendingAppointments
              : [
                  Appointment(
                    id: 'mock-pendente-1',
                    patientId: 'patient-1',
                    patientName: 'Roberto Gomes',
                    startDate: DateTime.now().subtract(const Duration(days: 2)),
                    endDate: DateTime.now().subtract(const Duration(days: 2, hours: -1)),
                    status: 'scheduled',
                    categoryId: 'MockCategory',
                    notes: 'Atendimento não finalizado',
                  ),
                  Appointment(
                    id: 'mock-pendente-2',
                    patientId: 'patient-2',
                    patientName: 'Fernanda Lima',
                    startDate: DateTime.now().subtract(const Duration(days: 5)),
                    endDate: DateTime.now().subtract(const Duration(days: 5, hours: -1)),
                    status: 'scheduled',
                  ),
                ],
          monthlyBirthdays: summary.monthlyBirthdays.isNotEmpty
              ? summary.monthlyBirthdays
              : [
                  {'name': 'Ana Silva', 'day': 5, 'photo': 'https://i.pravatar.cc/150?u=ana'},
                  {'name': 'Marcos Lima', 'day': 12, 'photo': 'https://i.pravatar.cc/150?u=marcos'},
                  {'name': 'Julia Costa', 'day': 22, 'photo': 'https://i.pravatar.cc/150?u=julia'},
                ],
          occupancyStats: summary.occupancyStats.isNotEmpty
              ? summary.occupancyStats
              : {
                  8: 3,
                  9: 5,
                  10: 8,
                  11: 6,
                  13: 4,
                  14: 7,
                  15: 9,
                  16: 5,
                  17: 3,
                  18: 2,
                },
          nextAppointment: summary.nextAppointment,
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
    emit(state.copyWith(status: DashboardStatus.loading, successMessage: null, errorMessage: null));
    try {
      // 1. Persiste no Backend
      await _updateAppointmentUseCase(event.appointment);

      // 2. Atualiza localmente para feedback instantâneo
      final updatedList = state.todaysAppointments.map((apt) {
        if (apt.id == event.appointment.id) {
          return event.appointment;
        }
        return apt;
      }).toList();

      emit(state.copyWith(
        status: DashboardStatus.success,
        todaysAppointments: updatedList,
        successMessage: 'Atendimento atualizado com sucesso!',
      ));

      // 3. Recarrega os dados do dashboard para atualizar métricas (faturamento, etc)
      add(const LoadDashboardData());
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}

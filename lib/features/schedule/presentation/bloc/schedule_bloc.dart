import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';
import 'package:physigest/features/schedule/domain/models/agenda_lock.dart';
import 'package:physigest/features/schedule/presentation/bloc/schedule_event.dart';
import 'package:physigest/features/schedule/presentation/bloc/schedule_state.dart';

import 'package:physigest/features/schedule/domain/usecases/schedule_usecases.dart';

@injectable
class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final GetAppointmentsUseCase _getAppointmentsUseCase;
  final CreateAppointmentUseCase _createAppointmentUseCase;
  final UpdateAppointmentUseCase _updateAppointmentUseCase;
  final GetAvailablePatientsUseCase _getAvailablePatientsUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final DeleteAppointmentUseCase _deleteAppointmentUseCase;
  final GetAgendaLocksUseCase _getAgendaLocksUseCase;
  final CreateAgendaLockUseCase _createAgendaLockUseCase;

  ScheduleBloc(
    this._getAppointmentsUseCase,
    this._createAppointmentUseCase,
    this._updateAppointmentUseCase,
    this._getAvailablePatientsUseCase,
    this._getCategoriesUseCase,
    this._deleteAppointmentUseCase,
    this._getAgendaLocksUseCase,
    this._createAgendaLockUseCase,
  ) : super(ScheduleState(selectedDate: DateTime.now())) {
    on<LoadSchedule>(_onLoadSchedule);
    on<SelectDate>(_onSelectDate);
    on<ChangeViewMode>(_onChangeViewMode);
    on<AddAppointment>(_onAddAppointment);
    on<UpdateAppointment>(_onUpdateAppointment);
    on<DeleteAppointment>(_onDeleteAppointment);
    on<AddAgendaLock>(_onAddAgendaLock);
  }

  Future<void> _onLoadSchedule(
    LoadSchedule event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(state.copyWith(
      status: ScheduleStatus.loading,
      resetSuccess: true,
      resetError: true,
    ));

    try {
      final results = await Future.wait([
        _getAvailablePatientsUseCase(),
        _getCategoriesUseCase(),
        _getAppointmentsUseCase(),
        _getAgendaLocksUseCase(),
      ]);

      final availablePatients = results[0] as List<Map<String, dynamic>>;
      final activeCategories = results[1] as List<Map<String, dynamic>>;
      final allAppointments = results[2] as List<Appointment>;
      final agendaLocks = results[3] as List<AgendaLock>;

      // Filtrar agendamentos para excluir pacientes inativos
      // (Se o patientId não estiver na lista de pacientes ativos, removemos).
      // Mantemos agendamentos sem patientId (casos de bloqueio manual ou erro de dados)
      // para não perder visibilidade de ocupação.
      final activePatientIds = availablePatients.map((e) => e['id']).toSet();
      final filteredAppointments = allAppointments.where((apt) {
        if (apt.patientId == null || apt.patientId!.isEmpty) return true;
        return activePatientIds.contains(apt.patientId);
      }).toList();

      emit(
        state.copyWith(
          status: ScheduleStatus.success,
          availablePatients: availablePatients,
          activeCategories: activeCategories,
          appointments: filteredAppointments,
          agendaLocks: agendaLocks,
          successMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          resetSuccess: true,
        ),
      );
    }
  }

  void _onSelectDate(SelectDate event, Emitter<ScheduleState> emit) {
    emit(state.copyWith(
      selectedDate: event.selectedDate,
      resetSuccess: true,
      resetError: true,
    ));
  }

  void _onChangeViewMode(ChangeViewMode event, Emitter<ScheduleState> emit) {
    emit(state.copyWith(
      viewMode: event.viewMode,
      resetSuccess: true,
      resetError: true,
    ));
  }

  Future<void> _onAddAppointment(
    AddAppointment event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(state.copyWith(
      status: ScheduleStatus.loading,
      resetSuccess: true,
      resetError: true,
    ));
    try {
      await _createAppointmentUseCase(event.appointment);
      emit(state.copyWith(
        status: ScheduleStatus.success,
        successMessage: 'Agendamento adicionado com sucesso!',
      ));
      add(LoadSchedule());
    } catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          resetSuccess: true,
        ),
      );
    }
  }

  Future<void> _onUpdateAppointment(
    UpdateAppointment event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(state.copyWith(
      status: ScheduleStatus.loading,
      resetSuccess: true,
      resetError: true,
    ));
    try {
      await _updateAppointmentUseCase(event.appointment);
      emit(state.copyWith(
        status: ScheduleStatus.success,
        successMessage: 'Agendamento atualizado com sucesso!',
      ));
      add(LoadSchedule());
    } catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          resetSuccess: true,
        ),
      );
    }
  }

  Future<void> _onDeleteAppointment(
    DeleteAppointment event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(state.copyWith(
      status: ScheduleStatus.loading,
      resetSuccess: true,
      resetError: true,
    ));
    try {
      await _deleteAppointmentUseCase(event.id);
      emit(state.copyWith(
        status: ScheduleStatus.success,
        successMessage: 'Agendamento removido com sucesso!',
      ));
      add(LoadSchedule());
    } catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          resetSuccess: true,
        ),
      );
    }
  }

  Future<void> _onAddAgendaLock(
    AddAgendaLock event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(state.copyWith(
      status: ScheduleStatus.loading,
      resetSuccess: true,
      resetError: true,
    ));
    try {
      await _createAgendaLockUseCase(event.lock);
      emit(state.copyWith(
        status: ScheduleStatus.success,
        successMessage: 'Bloqueio adicionado com sucesso!',
      ));
      add(LoadSchedule());
    } catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }
}

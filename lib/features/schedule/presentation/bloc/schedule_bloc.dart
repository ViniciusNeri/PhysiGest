import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';
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

  ScheduleBloc(
    this._getAppointmentsUseCase,
    this._createAppointmentUseCase,
    this._updateAppointmentUseCase,
    this._getAvailablePatientsUseCase,
    this._getCategoriesUseCase,
    this._deleteAppointmentUseCase,
  ) : super(ScheduleState(selectedDate: DateTime.now())) {
    on<LoadSchedule>(_onLoadSchedule);
    on<SelectDate>(_onSelectDate);
    on<ChangeViewMode>(_onChangeViewMode);
    on<AddAppointment>(_onAddAppointment);
    on<UpdateAppointment>(_onUpdateAppointment);
    on<DeleteAppointment>(_onDeleteAppointment);
  }

  Future<void> _onLoadSchedule(
    LoadSchedule event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(state.copyWith(status: ScheduleStatus.loading));

    try {
      final patients = await _getAvailablePatientsUseCase();
      final categories = await _getCategoriesUseCase();
      final appointments = await _getAppointmentsUseCase();

      emit(
        state.copyWith(
          status: ScheduleStatus.success,
          appointments: appointments,
          availablePatients: patients,
          activeCategories: categories,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  void _onSelectDate(SelectDate event, Emitter<ScheduleState> emit) {
    emit(state.copyWith(selectedDate: event.selectedDate));
  }

  void _onChangeViewMode(ChangeViewMode event, Emitter<ScheduleState> emit) {
    emit(state.copyWith(viewMode: event.viewMode));
  }

  Future<void> _onAddAppointment(
    AddAppointment event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      final created = await _createAppointmentUseCase(event.appointment);
      final updatedList = List<Appointment>.from(state.appointments)..add(created);
      emit(state.copyWith(status: ScheduleStatus.success, appointments: updatedList));
    } catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onUpdateAppointment(
    UpdateAppointment event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      final updated = await _updateAppointmentUseCase(event.appointment);
      final updatedList = state.appointments.map((apt) {
        if (apt.id == updated.id) return updated;
        return apt;
      }).toList();
      emit(state.copyWith(status: ScheduleStatus.success, appointments: updatedList));
    } catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onDeleteAppointment(
    DeleteAppointment event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      await _deleteAppointmentUseCase(event.id);
      final updatedList = state.appointments.where((apt) => apt.id != event.id).toList();
      emit(state.copyWith(status: ScheduleStatus.success, appointments: updatedList));
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

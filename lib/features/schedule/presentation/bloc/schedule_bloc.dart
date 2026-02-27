import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';
import 'package:physigest/features/schedule/presentation/bloc/schedule_event.dart';
import 'package:physigest/features/schedule/presentation/bloc/schedule_state.dart';

@injectable
class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  ScheduleBloc() : super(ScheduleState(selectedDate: DateTime.now())) {
    on<LoadSchedule>(_onLoadSchedule);
    on<SelectDate>(_onSelectDate);
    on<AddAppointment>(_onAddAppointment);
  }

  Future<void> _onLoadSchedule(LoadSchedule event, Emitter<ScheduleState> emit) async {
    emit(state.copyWith(status: ScheduleStatus.loading));

    try {
      // Simulando chamada de API para pacientes disponíveis
      await Future.delayed(const Duration(milliseconds: 500));
      final patients = [
        'Maria Silva',
        'João Santos',
        'Ana Costa',
        'Carlos Lima',
        'Paula Mendes',
        'Roberto Almeida',
      ];

      // Simulando appointments pré-existentes para visualizar no calendário
      final today = DateTime.now();
      final mockAppointments = [
        Appointment(
          id: '1',
          patientName: 'Maria Silva',
          type: 'Avaliação Inicial',
          date: today,
          time: '08:00',
        ),
        Appointment(
          id: '2',
          patientName: 'João Santos',
          type: 'Retorno',
          date: today.add(const Duration(days: 1)),
          time: '09:30',
        ),
        Appointment(
          id: '3',
          patientName: 'Ana Costa',
          type: 'Fisioterapia',
          date: today,
          time: '14:00',
        ),
      ];

      emit(state.copyWith(
        status: ScheduleStatus.success,
        appointments: mockAppointments,
        availablePatients: patients,
      ));
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: 'Erro ao carregar agenda.'));
    }
  }

  void _onSelectDate(SelectDate event, Emitter<ScheduleState> emit) {
    emit(state.copyWith(selectedDate: event.selectedDate));
  }

  void _onAddAppointment(AddAppointment event, Emitter<ScheduleState> emit) {
    final updatedList = List<Appointment>.from(state.appointments)..add(event.appointment);
    emit(state.copyWith(appointments: updatedList));
  }
}

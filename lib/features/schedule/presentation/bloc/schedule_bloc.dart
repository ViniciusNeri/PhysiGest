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
    on<UpdateAppointment>(_onUpdateAppointment);
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
          endTime: '09:00',
        ),
        Appointment(
          id: '2',
          patientName: 'João Santos',
          type: 'Retorno',
          date: today.add(const Duration(days: -1)),
          time: '09:30',
          endTime: '10:30',
        ),
        Appointment(
          id: '3',
          patientName: 'Ana Costa',
          type: 'Fisioterapia',
          date: today,
          time: '14:00',
          endTime: '15:00',
        ),
        Appointment(
          id: '4',
          patientName: 'Carlos Lima',
          type: 'Fisioterapia',
          date: today.add(const Duration(days: -1)),
          time: '14:00',
          endTime: '15:00',
        ),
        Appointment(
          id: '5',
          patientName: 'Paula Mendes',
          type: 'Fisioterapia',
          date: today,
          time: '16:00',
          endTime: '17:00',
        ),  
        Appointment(
          id: '6',
          patientName: 'Roberto Almeida',
          type: 'Fisioterapia',
          date: today.add(const Duration(days: -3)),
          time: '11:00',
          endTime: '13:00',
        ),
        Appointment(
          id: '7',
          patientName: 'Roberto Almeida',
          type: 'Fisioterapia',
          date: today.add(const Duration(days: -4)),
          time: '10:00',
          endTime: '11:00',
        ),
        Appointment(
          id: '8',
          patientName: 'Roberto Almeida',
          type: 'Fisioterapia',
          date: today.add(const Duration(days: -3)),
          time: '14:00',  
          endTime: '15:30',
        ),
        Appointment(
          id: '9',
          patientName: 'Roberto Almeida',
          type: 'Fisioterapia',
          date: today.add(const Duration(days: -2)),
          time: '18:00',  
          endTime: '20:00',
        ),
        Appointment(
          id: '10',
          patientName: 'Roberto Almeida',
          type: 'Fisioterapia',
          date: today,
          time: '18:00',
          endTime: '19:00',
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

  void _onUpdateAppointment(UpdateAppointment event, Emitter<ScheduleState> emit) {
    final updatedList = state.appointments.map((apt) {
      if (apt.id == event.appointment.id) {
        return event.appointment; // Substitui pelo novo
      }
      return apt;
    }).toList();
    emit(state.copyWith(appointments: updatedList));
  }

}

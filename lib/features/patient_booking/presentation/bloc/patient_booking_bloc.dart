import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';
import 'package:physigest/features/schedule/domain/repositories/i_schedule_repository.dart';
import 'patient_booking_event.dart';
import 'patient_booking_state.dart';

@injectable
class PatientBookingBloc extends Bloc<PatientBookingEvent, PatientBookingState> {
  final IScheduleRepository _repository;

  PatientBookingBloc(this._repository)
      : super(PatientBookingState(
          selectedDate: DateTime.now(),
          focusedDate: DateTime.now(),
        )) {
    on<LoadBookingData>(_onLoadBookingData);
    on<SelectBookingDate>(_onSelectBookingDate);
    on<SelectBookingSlot>(_onSelectBookingSlot);
    on<ConfirmBooking>(_onConfirmBooking);
    on<ChangeBookingMonth>(_onChangeBookingMonth);
    on<SelectBookingCategory>(_onSelectBookingCategory);
  }

  void _onLoadBookingData(LoadBookingData event, Emitter<PatientBookingState> emit) async {
    emit(state.copyWith(status: PatientBookingStatus.loading));
    try {
      final appointments = await _repository.getAppointments();
      final categories = await _repository.getCategories();
      emit(state.copyWith(
        status: PatientBookingStatus.initial,
        appointments: appointments,
        categories: categories,
        userId: event.userId,
      ));
      _calculateAvailableSlots(state.selectedDate, emit);
    } catch (e) {
      emit(state.copyWith(status: PatientBookingStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onSelectBookingDate(SelectBookingDate event, Emitter<PatientBookingState> emit) {
    emit(state.copyWith(selectedDate: event.date, selectedSlot: null));
    _calculateAvailableSlots(event.date, emit);
  }

  void _onSelectBookingSlot(SelectBookingSlot event, Emitter<PatientBookingState> emit) {
    emit(state.copyWith(selectedSlot: event.slot));
  }

  void _onChangeBookingMonth(ChangeBookingMonth event, Emitter<PatientBookingState> emit) {
    final newFocusedDate = DateTime(event.year, event.month, 1);
    emit(state.copyWith(
      focusedDate: newFocusedDate,
      selectedSlot: null,
    ));
    _calculateAvailableSlots(state.selectedDate, emit);
  }

  void _onSelectBookingCategory(SelectBookingCategory event, Emitter<PatientBookingState> emit) {
    emit(state.copyWith(selectedCategoryId: event.categoryId));
  }

  void _onConfirmBooking(ConfirmBooking event, Emitter<PatientBookingState> emit) async {
    if (state.selectedSlot == null) {
      emit(state.copyWith(status: PatientBookingStatus.failure, errorMessage: "Selecione um horário."));
      return;
    }

    if (state.selectedCategoryId == null) {
      emit(state.copyWith(status: PatientBookingStatus.failure, errorMessage: "Selecione o tipo de atendimento."));
      return;
    }

    if (event.pin != "1234") { // Validação Mock conforme solicitado para exibição de erro
      emit(state.copyWith(status: PatientBookingStatus.failure, errorMessage: "PIN incorreto tente novamente."));
      return;
    }

    emit(state.copyWith(status: PatientBookingStatus.loading));
    try {
      final category = state.categories.firstWhere((c) => c['id'] == state.selectedCategoryId);
      
      final newAppt = Appointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientName: "Agendamento PIN: ${event.pin}", 
        userId: state.userId,
        categoryId: state.selectedCategoryId,
        categoryName: category['name'],
        startDate: state.selectedSlot!,
        endDate: state.selectedSlot!.add(const Duration(hours: 1)),
        status: 'scheduled',
      );

      await _repository.createAppointment(newAppt);
      emit(state.copyWith(
        status: PatientBookingStatus.success,
        successMessage: "Solicitação de agendamento realizada com sucesso! em alguns instantes entraremos em contato para confirmar a solicitação",
      ));
    } catch (e) {
      emit(state.copyWith(status: PatientBookingStatus.failure, errorMessage: e.toString()));
    }
  }

  void _calculateAvailableSlots(DateTime date, Emitter<PatientBookingState> emit) {
    final List<DateTime> slots = [];
    final startOfDay = DateTime(date.year, date.month, date.day, 8);

    for (int i = 0; i <= 10; i++) {
      final slotTime = startOfDay.add(Duration(hours: i));
      
      // Verifica se já existe agendamento neste horário
      final isOccupied = state.appointments.any((appt) {
        return appt.startDate.isBefore(slotTime.add(const Duration(minutes: 59))) &&
               appt.endDate.isAfter(slotTime);
      });

      if (!isOccupied && slotTime.isAfter(DateTime.now())) {
        slots.add(slotTime);
      }
    }

    emit(state.copyWith(availableSlots: slots));
  }
}

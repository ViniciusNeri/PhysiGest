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
    on<ResetBookingStatus>(_onResetBookingStatus);
  }

  void _onLoadBookingData(LoadBookingData event, Emitter<PatientBookingState> emit) async {
    emit(state.copyWith(status: PatientBookingStatus.loading));
    try {
      final categories = await _repository.getCategories(userId: event.userId);
      
      final dateStr = "${state.selectedDate.year}-${state.selectedDate.month.toString().padLeft(2, '0')}-${state.selectedDate.day.toString().padLeft(2, '0')}";
      final slots = await _repository.getAvailableSlots(event.userId, dateStr);

      emit(state.copyWith(
        status: PatientBookingStatus.initial,
        categories: categories,
        userId: event.userId,
        availableSlots: slots,
      ));
    } catch (e) {
      emit(state.copyWith(status: PatientBookingStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onSelectBookingDate(SelectBookingDate event, Emitter<PatientBookingState> emit) async {
    if (state.userId == null) return;
    
    emit(state.copyWith(
      status: PatientBookingStatus.loading,
      selectedDate: event.date,
      selectedSlot: null,
    ));
    try {
      final dateStr = "${event.date.year}-${event.date.month.toString().padLeft(2, '0')}-${event.date.day.toString().padLeft(2, '0')}";
      final slots = await _repository.getAvailableSlots(state.userId!, dateStr);
      
      emit(state.copyWith(
        status: PatientBookingStatus.initial,
        availableSlots: slots,
      ));
    } catch (e) {
      emit(state.copyWith(status: PatientBookingStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onSelectBookingSlot(SelectBookingSlot event, Emitter<PatientBookingState> emit) {
    if (state.status == PatientBookingStatus.success) return; // Bloqueia novos cliques após sucesso
    emit(state.copyWith(selectedSlot: event.slot, status: PatientBookingStatus.initial));
  }

  void _onChangeBookingMonth(ChangeBookingMonth event, Emitter<PatientBookingState> emit) async {
    if (state.userId == null) return;

    final newFocusedDate = DateTime(event.year, event.month, 1);
    emit(state.copyWith(
      focusedDate: newFocusedDate,
      selectedSlot: null,
      status: PatientBookingStatus.loading,
    ));
    
    try {
      final dateStr = "${state.selectedDate.year}-${state.selectedDate.month.toString().padLeft(2, '0')}-${state.selectedDate.day.toString().padLeft(2, '0')}";
      final slots = await _repository.getAvailableSlots(state.userId!, dateStr);
      
      emit(state.copyWith(
        status: PatientBookingStatus.initial,
        availableSlots: slots,
      ));
    } catch (e) {
      // Falha silenciosa ou log na troca de mês para não quebrar a navegação
    }
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

    emit(state.copyWith(status: PatientBookingStatus.loading));
    try {
      await _repository.createOnlineAppointment(
        userId: state.userId!,
        pin: event.pin,
        startDate: state.selectedSlot!,
        categoryId: state.selectedCategoryId!,
      );

      emit(state.copyWith(
        status: PatientBookingStatus.success,
        successMessage: "✨ Tudo pronto! Seu agendamento foi realizado com sucesso.\n\nEm instantes, nossa equipe entrará em contato para confirmar os detalhes. Obrigado pela confiança!",
      ));
    } catch (e) {
      emit(state.copyWith(status: PatientBookingStatus.failure, errorMessage: e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onResetBookingStatus(ResetBookingStatus event, Emitter<PatientBookingState> emit) {
    emit(state.copyWith(
      status: PatientBookingStatus.initial,
      selectedSlot: null,
      successMessage: null,
    ));
  }
}

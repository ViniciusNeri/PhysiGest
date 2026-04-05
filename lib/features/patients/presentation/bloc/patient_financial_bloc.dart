import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/patient_usecases.dart';
import 'patient_financial_event.dart';
import 'patient_financial_state.dart';

@injectable
class PatientFinancialBloc extends Bloc<PatientFinancialEvent, PatientFinancialState> {
  final GetFinancialSummaryUseCase _getFinancialSummaryUseCase;
  final AddFinancialRecordUseCase _addFinancialRecordUseCase;
  final UpdateFinancialStatusUseCase _updateFinancialStatusUseCase;

  PatientFinancialBloc(
    this._getFinancialSummaryUseCase,
    this._addFinancialRecordUseCase,
    this._updateFinancialStatusUseCase,
  ) : super(const PatientFinancialState()) {
    on<LoadFinancialSummary>(_onLoadFinancialSummary);
    on<AddFinancialPayment>(_onAddFinancialPayment);
    on<UpdatePaymentStatus>(_onUpdatePaymentStatus);
  }

  Future<void> _onLoadFinancialSummary(
    LoadFinancialSummary event,
    Emitter<PatientFinancialState> emit,
  ) async {
    emit(state.copyWith(status: PatientFinancialStatus.loading));
    try {
      final summary = await _getFinancialSummaryUseCase(event.patientId);
      emit(state.copyWith(status: PatientFinancialStatus.success, summary: summary));
    } catch (e) {
      emit(state.copyWith(
        status: PatientFinancialStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onAddFinancialPayment(
    AddFinancialPayment event,
    Emitter<PatientFinancialState> emit,
  ) async {
    emit(state.copyWith(status: PatientFinancialStatus.addingPayment));
    try {
      await _addFinancialRecordUseCase(event.patientId, event.payment);
      
      // Reload summary after adding payment
      final summary = await _getFinancialSummaryUseCase(event.patientId);
      
      emit(state.copyWith(
        status: PatientFinancialStatus.paymentAdded,
        summary: summary,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PatientFinancialStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpdatePaymentStatus(
    UpdatePaymentStatus event,
    Emitter<PatientFinancialState> emit,
  ) async {
    emit(state.copyWith(status: PatientFinancialStatus.loading));
    try {
      await _updateFinancialStatusUseCase(
        event.patientId,
        event.paymentId,
        event.status,
        paymentMethod: event.paymentMethod,
      );


      // Reload summary after updating status
      final summary = await _getFinancialSummaryUseCase(event.patientId);

      emit(state.copyWith(
        status: PatientFinancialStatus.statusUpdated,
        summary: summary,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PatientFinancialStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:physigest/features/patients/domain/models/patient.dart';
import 'package:physigest/features/patients/domain/usecases/patient_usecases.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_event.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_state.dart';

@injectable
class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final GetPatientsUseCase _getPatientsUseCase;
  final CreatePatientUseCase _createPatientUseCase;
  final UpdatePatientUseCase _updatePatientUseCase;
  final DeletePatientUseCase _deletePatientUseCase;

  PatientBloc(
    this._getPatientsUseCase,
    this._createPatientUseCase,
    this._updatePatientUseCase,
    this._deletePatientUseCase,
  ) : super(const PatientState()) {
    on<LoadPatients>(_onLoadPatients);
    on<AddPatient>(_onAddPatient);
    on<UpdatePatient>(_onUpdatePatient);
    on<DeletePatient>(_onDeletePatient);
    on<AddPhotoToPatient>(_onAddPhotoToPatient);
    on<ClearPatientMessages>(_onClearMessages);
  }

  void _onClearMessages(
    ClearPatientMessages event,
    Emitter<PatientState> emit,
  ) {
    emit(state.copyWith(status: PatientStatus.initial, clearMessages: true));
  }

  Future<void> _onLoadPatients(
    LoadPatients event,
    Emitter<PatientState> emit,
  ) async {
    emit(state.copyWith(status: PatientStatus.loading, clearMessages: true));
    try {
      final patients = await _getPatientsUseCase();
      emit(
        state.copyWith(
          status: PatientStatus.success,
          patients: patients,
          clearMessages: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PatientStatus.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onAddPatient(AddPatient event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading, clearMessages: true));
    try {
      final newPatient = await _createPatientUseCase(event.patient);
      emit(state.copyWith(
        status: PatientStatus.success,
        patients: List.of(state.patients)..add(newPatient),
        successMessage: 'Paciente adicionado com sucesso!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PatientStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpdatePatient(UpdatePatient event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading, clearMessages: true));
    try {
      final updatedPatient = await _updatePatientUseCase(event.patient);
      final updatedList = state.patients
          .map((p) => p.id == updatedPatient.id ? updatedPatient : p)
          .toList();
      emit(state.copyWith(
        status: PatientStatus.success,
        patients: updatedList,
        successMessage: 'Paciente atualizado com sucesso!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PatientStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onDeletePatient(DeletePatient event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading, clearMessages: true));
    try {
      await _deletePatientUseCase(event.id);
      final updatedList = state.patients.where((p) => p.id != event.id).toList();
      emit(state.copyWith(
        status: PatientStatus.success,
        patients: updatedList,
        successMessage: 'Paciente removido com sucesso!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PatientStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void _onAddPhotoToPatient(
    AddPhotoToPatient event,
    Emitter<PatientState> emit,
  ) {
    final updatedList = state.patients.map((p) {
      if (p.id == event.patientId) {
        final newPhotos = List<String>.from(p.photoPaths)..add(event.photoPath);
        return p.copyWith(photoPaths: newPhotos);
      }
      return p;
    }).toList();
    emit(state.copyWith(patients: updatedList));
  }
}

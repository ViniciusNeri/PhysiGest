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
  }

  Future<void> _onLoadPatients(
    LoadPatients event,
    Emitter<PatientState> emit,
  ) async {
    emit(state.copyWith(status: PatientStatus.loading));
    try {
      final patients = await _getPatientsUseCase();
      emit(
        state.copyWith(status: PatientStatus.success, patients: patients),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PatientStatus.failure,
          errorMessage: 'Erro ao carregar pacientes.',
        ),
      );
    }
  }

  Future<void> _onAddPatient(AddPatient event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading));
    try {
      final newPatient = await _createPatientUseCase(event.patient);
      emit(state.copyWith(
        status: PatientStatus.success,
        patients: List.of(state.patients)..add(newPatient),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PatientStatus.failure,
        errorMessage: 'Erro ao cadastrar paciente.',
      ));
    }
  }

  Future<void> _onUpdatePatient(UpdatePatient event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading));
    try {
      final updatedPatient = await _updatePatientUseCase(event.patient);
      final updatedList = state.patients
          .map((p) => p.id == updatedPatient.id ? updatedPatient : p)
          .toList();
      emit(state.copyWith(status: PatientStatus.success, patients: updatedList));
    } catch (e) {
      emit(state.copyWith(
        status: PatientStatus.failure,
        errorMessage: 'Erro ao atualizar paciente.',
      ));
    }
  }

  Future<void> _onDeletePatient(DeletePatient event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading));
    try {
      await _deletePatientUseCase(event.id);
      final updatedList = state.patients.where((p) => p.id != event.id).toList();
      emit(state.copyWith(status: PatientStatus.success, patients: updatedList));
    } catch (e) {
      emit(state.copyWith(
        status: PatientStatus.failure,
        errorMessage: 'Erro ao excluir paciente.',
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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:physigest/features/patients/domain/models/patient.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_event.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_state.dart';

@injectable
class PatientBloc extends Bloc<PatientEvent, PatientState> {
  PatientBloc() : super(const PatientState()) {
    on<LoadPatients>(_onLoadPatients);
    on<AddPatient>(_onAddPatient);
    on<UpdatePatient>(_onUpdatePatient);
    on<AddPhotoToPatient>(_onAddPhotoToPatient);
  }

  Future<void> _onLoadPatients(LoadPatients event, Emitter<PatientState> emit) async {
    emit(state.copyWith(status: PatientStatus.loading));
    try {
      await Future.delayed(const Duration(milliseconds: 600)); // Mock API call
      final mockPatients = [
        const Patient(
          id: '1',
          name: 'Maria Silva',
          email: 'maria.silva@email.com',
          phone: '(11) 98765-4321',
          birthDate: '15/05/1985',
          occupation: 'Professora',
          anamnesis: Anamnesis(mainComplaint: 'Dor lombar ao ficar muito tempo de pé.'),
        ),
        const Patient(
          id: '2',
          name: 'João Santos',
          email: 'joao.santos@email.com',
          phone: '(11) 91234-5678',
          birthDate: '10/11/1990',
          occupation: 'Engenheiro',
          anamnesis: Anamnesis(mainComplaint: 'Recuperação pós-operatória LCA joelho direito.'),
        ),
      ];
      emit(state.copyWith(status: PatientStatus.success, patients: mockPatients));
    } catch (e) {
      emit(state.copyWith(status: PatientStatus.failure, errorMessage: 'Erro ao carregar pacientes.'));
    }
  }

  void _onAddPatient(AddPatient event, Emitter<PatientState> emit) {
    emit(state.copyWith(patients: List.of(state.patients)..add(event.patient)));
  }

  void _onUpdatePatient(UpdatePatient event, Emitter<PatientState> emit) {
    final updatedList = state.patients.map((p) => p.id == event.patient.id ? event.patient : p).toList();
    emit(state.copyWith(patients: updatedList));
  }

  void _onAddPhotoToPatient(AddPhotoToPatient event, Emitter<PatientState> emit) {
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

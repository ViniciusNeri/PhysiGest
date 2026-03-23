import 'package:injectable/injectable.dart';
import 'package:physigest/features/patients/domain/models/patient.dart';
import '../repositories/i_patient_repository.dart';

@lazySingleton
class GetPatientsUseCase {
  final IPatientRepository repository;
  GetPatientsUseCase(this.repository);
  Future<List<Patient>> call() => repository.getPatients();
}

@lazySingleton
class GetPatientByIdUseCase {
  final IPatientRepository repository;
  GetPatientByIdUseCase(this.repository);
  Future<Patient> call(String id) => repository.getPatientById(id);
}

@lazySingleton
class CreatePatientUseCase {
  final IPatientRepository repository;
  CreatePatientUseCase(this.repository);
  Future<Patient> call(Patient patient) => repository.createPatient(patient);
}

@lazySingleton
class UpdatePatientUseCase {
  final IPatientRepository repository;
  UpdatePatientUseCase(this.repository);
  Future<Patient> call(Patient patient) => repository.updatePatient(patient);
}

@lazySingleton
class DeletePatientUseCase {
  final IPatientRepository repository;
  DeletePatientUseCase(this.repository);
  Future<void> call(String id) => repository.deletePatient(id);
}

@lazySingleton
class UpdateAnamnesisUseCase {
  final IPatientRepository repository;
  UpdateAnamnesisUseCase(this.repository);
  Future<Patient> call(String patientId, Anamnesis anamnesis) =>
      repository.updateAnamnesis(patientId, anamnesis);
}

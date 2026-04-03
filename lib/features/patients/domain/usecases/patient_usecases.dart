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
  Future<Anamnesis> call(String patientId, String anamnesisId, Anamnesis anamnesis) =>
      repository.updateAnamnesis(patientId, anamnesisId, anamnesis);
}

@lazySingleton
class GetLatestAnamnesisUseCase {
  final IPatientRepository repository;
  GetLatestAnamnesisUseCase(this.repository);
  Future<Anamnesis?> call(String patientId) => repository.getLatestAnamnesis(patientId);
}

@lazySingleton
class CreateAnamnesisUseCase {
  final IPatientRepository repository;
  CreateAnamnesisUseCase(this.repository);
  Future<Anamnesis> call(String patientId, Anamnesis anamnesis) =>
      repository.createAnamnesis(patientId, anamnesis);
}

@lazySingleton
class GetFinancialSummaryUseCase {
  final IPatientRepository repository;
  GetFinancialSummaryUseCase(this.repository);
  Future<PatientFinancialSummary> call(String patientId) =>
      repository.getFinancialSummary(patientId);
}

@lazySingleton
class AddFinancialRecordUseCase {
  final IPatientRepository repository;
  AddFinancialRecordUseCase(this.repository);
  Future<void> call(String patientId, PatientPayment payment) =>
      repository.addFinancialRecord(patientId, payment);
}

@lazySingleton
class UpdateFinancialStatusUseCase {
  final IPatientRepository repository;
  UpdateFinancialStatusUseCase(this.repository);
  Future<void> call(String patientId, String paymentId, String status, {String? paymentMethod}) =>
      repository.updateFinancialRecordStatus(patientId, paymentId, status, paymentMethod: paymentMethod);
}

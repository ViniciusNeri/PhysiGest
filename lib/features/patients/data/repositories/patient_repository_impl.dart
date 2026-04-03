import 'package:injectable/injectable.dart';
import 'package:physigest/features/patients/domain/models/patient.dart';
import '../../domain/repositories/i_patient_repository.dart';
import '../datasources/patient_remote_datasource.dart';

@LazySingleton(as: IPatientRepository)
class PatientRepositoryImpl implements IPatientRepository {
  final IPatientRemoteDataSource remoteDataSource;

  PatientRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Patient>> getPatients() async {
    return await remoteDataSource.getPatients();
  }

  @override
  Future<Patient> getPatientById(String id) async {
    return await remoteDataSource.getPatientById(id);
  }

  @override
  Future<Patient> createPatient(Patient patient) async {
    return await remoteDataSource.createPatient(patient);
  }

  @override
  Future<Patient> updatePatient(Patient patient) async {
    return await remoteDataSource.updatePatient(patient);
  }

  @override
  Future<void> deletePatient(String id) async {
    return await remoteDataSource.deletePatient(id);
  }

  @override
  Future<Anamnesis?> getLatestAnamnesis(String patientId) async {
    return await remoteDataSource.getLatestAnamnesis(patientId);
  }

  @override
  Future<Anamnesis> createAnamnesis(String patientId, Anamnesis anamnesis) async {
    return await remoteDataSource.createAnamnesis(patientId, anamnesis);
  }

  @override
  Future<Anamnesis> updateAnamnesis(
    String patientId,
    String anamnesisId,
    Anamnesis anamnesis,
  ) async {
    return await remoteDataSource.updateAnamnesis(patientId, anamnesisId, anamnesis);
  }

  @override
  Future<PatientFinancialSummary> getFinancialSummary(String patientId) async {
    return await remoteDataSource.getFinancialSummary(patientId);
  }

  @override
  Future<void> addFinancialRecord(String patientId, PatientPayment payment) async {
    return await remoteDataSource.addFinancialRecord(patientId, payment);
  }

  @override
  Future<void> updateFinancialRecordStatus(
    String patientId,
    String paymentId,
    String status, {
    String? paymentMethod,
  }) async {
    return await remoteDataSource.updateFinancialRecordStatus(
      patientId,
      paymentId,
      status,
      paymentMethod: paymentMethod,
    );
  }
}

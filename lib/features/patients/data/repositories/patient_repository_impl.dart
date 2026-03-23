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
  Future<Patient> updateAnamnesis(String patientId, Anamnesis anamnesis) async {
    return await remoteDataSource.updateAnamnesis(patientId, anamnesis);
  }
}

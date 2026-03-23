import 'package:physigest/features/patients/domain/models/patient.dart';

abstract class IPatientRepository {
  Future<List<Patient>> getPatients();
  Future<Patient> getPatientById(String id);
  Future<Patient> createPatient(Patient patient);
  Future<Patient> updatePatient(Patient patient);
  Future<void> deletePatient(String id);
  Future<Patient> updateAnamnesis(String patientId, Anamnesis anamnesis);
}

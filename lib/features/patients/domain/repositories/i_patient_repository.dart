import 'package:physigest/features/patients/domain/models/patient.dart';
import 'package:physigest/features/patients/domain/models/appointment.dart';
import 'package:physigest/features/patients/domain/models/patient_activity.dart';

abstract class IPatientRepository {
  Future<List<Patient>> getPatients();
  Future<Patient> getPatientById(String id);
  Future<Patient> createPatient(Patient patient);
  Future<Patient> updatePatient(Patient patient);
  Future<void> deletePatient(String id);
  Future<Anamnesis?> getLatestAnamnesis(String patientId);
  Future<Anamnesis> createAnamnesis(String patientId, Anamnesis anamnesis);
  Future<Anamnesis> updateAnamnesis(String patientId, String anamnesisId, Anamnesis anamnesis);
  Future<List<Appointment>> getPatientAgenda(String patientId);
  Future<List<PatientActivity>> getPatientActivities(String patientId);
  Future<PatientFinancialSummary> getFinancialSummary(String patientId);
  Future<void> addFinancialRecord(String patientId, PatientPayment payment);
  Future<void> updateFinancialRecordStatus(String patientId, String paymentId, String status, {String? paymentMethod});
}

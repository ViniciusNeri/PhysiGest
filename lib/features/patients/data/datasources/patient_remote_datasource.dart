import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import 'package:physigest/features/patients/domain/models/patient.dart';
import '../models/patient_model.dart';

abstract class IPatientRemoteDataSource {
  Future<List<PatientModel>> getPatients();
  Future<PatientModel> getPatientById(String id);
  Future<PatientModel> createPatient(Patient patient);
  Future<PatientModel> updatePatient(Patient patient);
  Future<void> deletePatient(String id);
  Future<PatientModel> updateAnamnesis(String patientId, Anamnesis anamnesis);
}

@LazySingleton(as: IPatientRemoteDataSource)
class PatientRemoteDataSource implements IPatientRemoteDataSource {
  final ApiClient apiClient;

  PatientRemoteDataSource(this.apiClient);

  @override
  Future<List<PatientModel>> getPatients() async {
    try {
      final response = await apiClient.dio.get('/patients');
      final list = response.data as List<dynamic>;
      return list.map((json) => PatientModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Erro ao buscar pacientes.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar pacientes: $e');
    }
  }

  @override
  Future<PatientModel> getPatientById(String id) async {
    try {
      final response = await apiClient.dio.get('/patients/$id');
      return PatientModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Erro ao buscar paciente.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar paciente: $e');
    }
  }

  @override
  Future<PatientModel> createPatient(Patient patient) async {
    try {
      final body = PatientModel(
        id: patient.id,
        name: patient.name,
        email: patient.email,
        phone: patient.phone,
        birthDate: patient.birthDate,
        occupation: patient.occupation,
        anamnesis: patient.anamnesis,
        photoPaths: patient.photoPaths,
        financialHistory: patient.financialHistory,
      ).toJson();
      final response = await apiClient.dio.post('/patients', data: body);
      return PatientModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Erro ao cadastrar paciente.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido ao cadastrar paciente: $e');
    }
  }

  @override
  Future<PatientModel> updatePatient(Patient patient) async {
    try {
      final body = PatientModel(
        id: patient.id,
        name: patient.name,
        email: patient.email,
        phone: patient.phone,
        birthDate: patient.birthDate,
        occupation: patient.occupation,
        anamnesis: patient.anamnesis,
        photoPaths: patient.photoPaths,
        financialHistory: patient.financialHistory,
      ).toJson();
      final response = await apiClient.dio.put('/patients/${patient.id}', data: body);
      return PatientModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Erro ao atualizar paciente.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido ao atualizar paciente: $e');
    }
  }

  @override
  Future<void> deletePatient(String id) async {
    try {
      await apiClient.dio.delete('/patients/$id');
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Erro ao excluir paciente.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido ao excluir paciente: $e');
    }
  }

  @override
  Future<PatientModel> updateAnamnesis(String patientId, Anamnesis anamnesis) async {
    try {
      final body = {
        'mainComplaint': anamnesis.mainComplaint,
        'currentIllness': anamnesis.currentIllness,
        'historic': anamnesis.historic,
        'familyHistory': anamnesis.familyHistory,
        'lifestyleHabits': anamnesis.lifestyleHabits,
        'physicalExam': anamnesis.physicalExam,
        'clinicalDiagnosis': anamnesis.clinicalDiagnosis,
        'treatmentPlan': anamnesis.treatmentPlan,
        'medications': anamnesis.medications,
      };
      final response = await apiClient.dio.put('/patients/$patientId/anamnesis', data: body);
      return PatientModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Erro ao atualizar anamnese.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido ao atualizar anamnese: $e');
    }
  }
}

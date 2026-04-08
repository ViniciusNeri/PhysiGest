import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import 'package:physigest/features/patients/domain/models/patient.dart';
import '../models/patient_model.dart';
import '../models/anamnesis_model.dart';
import '../models/appointment_model.dart';
import '../models/patient_financial_model.dart';
import '../models/patient_activity_model.dart';
import 'package:physigest/core/storage/local_storage.dart';

abstract class IPatientRemoteDataSource {
  Future<List<PatientModel>> getPatients();
  Future<PatientModel> getPatientById(String id);
  Future<PatientModel> createPatient(Patient patient);
  Future<PatientModel> updatePatient(Patient patient);
  Future<void> deletePatient(String id);
  Future<Anamnesis?> getLatestAnamnesis(String patientId);
  Future<Anamnesis> createAnamnesis(String patientId, Anamnesis anamnesis);
  Future<Anamnesis> updateAnamnesis(String patientId, String anamnesisId, Anamnesis anamnesis);
  Future<List<AppointmentModel>> getPatientAgenda(String patientId);
  Future<List<PatientActivityModel>> getPatientActivities(String patientId);
  Future<PatientFinancialSummary> getFinancialSummary(String patientId);
  Future<void> addFinancialRecord(String patientId, PatientPayment payment);
  Future<void> updateFinancialRecordStatus(String patientId, String paymentId, String status, {String? paymentMethod});
}

@LazySingleton(as: IPatientRemoteDataSource)
class PatientRemoteDataSource implements IPatientRemoteDataSource {
  final ApiClient apiClient;
  final LocalStorage localStorage;

  PatientRemoteDataSource(this.apiClient, this.localStorage);

  @override
  Future<List<PatientModel>> getPatients() async {
    try {
      final user = await localStorage.getUser();
      final userId = user?.id ?? '';
      final response = await apiClient.dio.get('/patients/user/$userId');
      final list = response.data as List<dynamic>;
      return list.map((json) => PatientModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erroinesperado: $e');
    }
  }

  @override
  Future<PatientModel> getPatientById(String id) async {
    try {
      final response = await apiClient.dio.get('/patients/$id');
      return PatientModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
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
        gender: patient.gender,
        profession: patient.profession,
        completedAppointments: patient.completedAppointments,
        noShowAppointments: patient.noShowAppointments,
        nextAppointmentDate: patient.nextAppointmentDate,
        anamnesis: patient.anamnesis,
        photoPaths: patient.photoPaths,
        pin: patient.pin.isEmpty ? _generateRandomPin() : patient.pin,
        status: patient.status,
      ).toJson();
      
      final user = await localStorage.getUser();
      final userId = user?.id ?? '';
      body['userId'] = userId;

      final response = await apiClient.dio.post('/patients', data: body);
      return PatientModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
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
        gender: patient.gender,
        profession: patient.profession,
        completedAppointments: patient.completedAppointments,
        noShowAppointments: patient.noShowAppointments,
        nextAppointmentDate: patient.nextAppointmentDate,
        anamnesis: patient.anamnesis,
        photoPaths: patient.photoPaths,
        pin: patient.pin,
        status: patient.status,
      ).toJson();
      final response = await apiClient.dio.put(
        '/patients/${patient.id}',
        data: body,
      );
      return PatientModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  @override
  Future<void> deletePatient(String id) async {
    try {
      await apiClient.dio.delete('/patients/$id');
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  @override
  Future<Anamnesis?> getLatestAnamnesis(String patientId) async {
    try {
      final response = await apiClient.dio.get('/patients/$patientId/anamnesis/latest');
      if (response.data == null || response.data.isEmpty) return null;
      return AnamnesisModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  @override
  Future<Anamnesis> createAnamnesis(String patientId, Anamnesis anamnesis) async {
    try {
      final body = AnamnesisModel.fromDomain(anamnesis).toJson();
      final response = await apiClient.dio.post('/patients/$patientId/anamnesis', data: body);
      return AnamnesisModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  @override
  Future<Anamnesis> updateAnamnesis(
    String patientId,
    String anamnesisId,
    Anamnesis anamnesis,
  ) async {
    try {
      final body = AnamnesisModel.fromDomain(anamnesis).toJson();
      final response = await apiClient.dio.put(
        '/patients/$patientId/anamnesis/$anamnesisId',
        data: body,
      );
      return AnamnesisModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  @override
  Future<List<AppointmentModel>> getPatientAgenda(String patientId) async {
    try {
      final response = await apiClient.dio.get('/agendas/patient/$patientId');
      final list = response.data as List<dynamic>;
      return list.map((json) => AppointmentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  @override
  Future<List<PatientActivityModel>> getPatientActivities(String patientId) async {
    try {
      final response = await apiClient.dio.get('/patients/$patientId/activities');
      final list = response.data as List<dynamic>;
      return list.map((json) => PatientActivityModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  @override
  Future<PatientFinancialSummary> getFinancialSummary(String patientId) async {
    try {
      final response = await apiClient.dio.get('/patients/$patientId/financial/summary');
      return PatientFinancialSummaryModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  @override
  Future<void> addFinancialRecord(String patientId, PatientPayment payment) async {
    try {
      final body = PatientPaymentModel(
        id: payment.id,
        patientId: payment.patientId,
        userId: payment.userId,
        type: payment.type,
        category: payment.category,
        description: payment.description,
        amount: payment.amount,
        date: payment.date,
        paymentMethod: payment.paymentMethod,
        status: payment.status,
        dueDate: payment.dueDate,
        paymentDate: payment.paymentDate,
        notes: payment.notes,
        totalSessions: payment.totalSessions,
      ).toJson();
      await apiClient.dio.post('/patients/$patientId/financial', data: body);
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  @override
  Future<void> updateFinancialRecordStatus(
    String patientId,
    String paymentId,
    String status, {
    String? paymentMethod,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (paymentMethod != null) {
        data['paymentMethod'] = paymentMethod;
      }
      await apiClient.dio.patch(
        '/patients/$patientId/financial/$paymentId/pay',
        data: data,
      );
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  String _generateRandomPin() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return random.substring(random.length - 4);
  }
}

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';
import '../models/appointment_model.dart';
import 'package:physigest/core/storage/local_storage.dart';

abstract class IScheduleRemoteDataSource {
  Future<List<AppointmentModel>> getAppointments();
  Future<AppointmentModel> createAppointment(Appointment appointment);
  Future<AppointmentModel> updateAppointment(Appointment appointment);
  Future<void> deleteAppointment(String id);
  Future<List<Map<String, dynamic>>> getAvailablePatients();
  Future<List<Map<String, dynamic>>> getCategories();
}

@LazySingleton(as: IScheduleRemoteDataSource)
class ScheduleRemoteDataSource implements IScheduleRemoteDataSource {
  final ApiClient apiClient;
  final LocalStorage localStorage;

  ScheduleRemoteDataSource(this.apiClient, this.localStorage);

  @override
  Future<List<AppointmentModel>> getAppointments() async {
    try {
      final response = await apiClient.dio.get('/agendas');
      final list = response.data as List<dynamic>;
      return list.map((json) => AppointmentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? 'Erro ao buscar agendas.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar agendas: $e');
    }
  }

  @override
  Future<AppointmentModel> createAppointment(Appointment appointment) async {
    try {
      final user = await localStorage.getUser();
      final userId = user?.id ?? '';
      
      final body = AppointmentModel(
        id: appointment.id,
        patientName: appointment.patientName,
        patientId: appointment.patientId,
        userId: appointment.userId ?? userId,
        categoryId: appointment.categoryId,
        startDate: appointment.startDate,
        endDate: appointment.endDate,
        status: appointment.status,
        description: appointment.description,
        notes: appointment.notes,
      ).toJson();
      final response = await apiClient.dio.post('/agendas', data: body);
      return AppointmentModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? 'Erro ao criar agendamento.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido ao criar agendamento: $e');
    }
  }

  @override
  Future<AppointmentModel> updateAppointment(Appointment appointment) async {
    try {
      final user = await localStorage.getUser();
      final currentUserId = user?.id ?? '';

      final body = AppointmentModel(
        id: appointment.id,
        patientName: appointment.patientName,
        patientId: appointment.patientId,
        userId: appointment.userId ?? currentUserId,
        categoryId: appointment.categoryId,
        startDate: appointment.startDate,
        endDate: appointment.endDate,
        status: appointment.status,
        description: appointment.description,
        notes: appointment.notes,
      ).toJson();
      final response = await apiClient.dio.put(
        '/agendas/${appointment.id}',
        data: body,
      );
      return AppointmentModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? 'Erro ao atualizar agendamento.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido ao atualizar agendamento: $e');
    }
  }

  @override
  Future<void> deleteAppointment(String id) async {
    try {
      await apiClient.dio.delete('/agendas/$id');
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? 'Erro ao excluir agendamento.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido ao excluir agendamento: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAvailablePatients() async {
    try {
      final user = await localStorage.getUser();
      final userId = user?.id ?? '';
      if (userId.isEmpty) return [];

      final response = await apiClient.dio.get('/patients/user/$userId');
      final list = response.data as List<dynamic>;
      return list.map((e) => {
        'id': e['_id']?.toString() ?? e['id']?.toString() ?? '',
        'name': e['name']?.toString() ?? '',
      }).toList();
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ??
          'Erro ao buscar pacientes disponíveis.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar pacientes: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final user = await localStorage.getUser();
      final userId = user?.id ?? '';
      if (userId.isEmpty) return [];

      final response = await apiClient.dio.get('/categories/user/$userId');
      final list = response.data as List<dynamic>;
      return list.map((e) => {
        'id': e['_id']?.toString() ?? e['id']?.toString() ?? '',
        'name': e['description']?.toString() ?? '',
      }).toList();
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ??
          'Erro ao buscar categorias disponíveis.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar categorias: $e');
    }
  }
}

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';
import 'package:physigest/features/schedule/domain/models/agenda_lock.dart';
import '../models/appointment_model.dart';
import '../models/agenda_lock_model.dart';
import 'package:physigest/core/storage/local_storage.dart';

abstract class IScheduleRemoteDataSource {
  Future<List<AppointmentModel>> getAppointments();
  Future<AppointmentModel> createAppointment(Appointment appointment);
  Future<AppointmentModel> updateAppointment(Appointment appointment);
  Future<void> deleteAppointment(String id);
  Future<List<Map<String, dynamic>>> getAvailablePatients();
  Future<List<Map<String, dynamic>>> getCategories();
  Future<List<AgendaLockModel>> getAgendaLocks();
  Future<AgendaLockModel> createAgendaLock(AgendaLock lock);
}

@LazySingleton(as: IScheduleRemoteDataSource)
class ScheduleRemoteDataSource implements IScheduleRemoteDataSource {
  final ApiClient apiClient;
  final LocalStorage localStorage;

  ScheduleRemoteDataSource(this.apiClient, this.localStorage);

  @override
  Future<List<AppointmentModel>> getAppointments() async {
    try {
      final user = await localStorage.getUser();
      final userId = user?.id ?? '';
      if (userId.isEmpty) return [];

      final response = await apiClient.dio.get('/agendas/user/$userId');
      final list = response.data as List<dynamic>;
      return list.map((json) => AppointmentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
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
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
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
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  @override
  Future<void> deleteAppointment(String id) async {
    try {
      await apiClient.dio.delete('/agendas/$id');
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
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
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
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
        'name': e['name']?.toString() ?? e['description']?.toString() ?? '',
      }).toList();
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  @override
  Future<List<AgendaLockModel>> getAgendaLocks() async {
    try {
      final user = await localStorage.getUser();
      final userId = user?.id ?? '';
      if (userId.isEmpty) return [];

      final response = await apiClient.dio.get('/agendas/user/$userId/locks');
      final list = response.data as List<dynamic>;
      return list.map((json) => AgendaLockModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  @override
  Future<AgendaLockModel> createAgendaLock(AgendaLock lock) async {
    try {
      final user = await localStorage.getUser();
      final userId = user?.id ?? '';

      final body = AgendaLockModel(
        id: lock.id,
        userId: lock.userId.isEmpty ? userId : lock.userId,
        type: lock.type,
        date: lock.date,
        dates: lock.dates,
        startTime: lock.startTime,
        endTime: lock.endTime,
        description: lock.description,
      ).toJson();

      final response = await apiClient.dio.post('/agendas/lock', data: body);
      
      // Se a resposta for uma lista (lote), pegar o primeiro item
      if (response.data is List && (response.data as List).isNotEmpty) {
        return AgendaLockModel.fromJson(response.data[0]);
      }
      
      // Caso contrário, tratar como objeto único
      return AgendaLockModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}

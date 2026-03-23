import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';
import '../models/appointment_model.dart';

abstract class IScheduleRemoteDataSource {
  Future<List<AppointmentModel>> getAppointments(DateTime from, DateTime to);
  Future<AppointmentModel> createAppointment(Appointment appointment);
  Future<AppointmentModel> updateAppointment(Appointment appointment);
  Future<void> deleteAppointment(String id);
  Future<List<String>> getAvailablePatients();
}

@LazySingleton(as: IScheduleRemoteDataSource)
class ScheduleRemoteDataSource implements IScheduleRemoteDataSource {
  final ApiClient apiClient;

  ScheduleRemoteDataSource(this.apiClient);

  @override
  Future<List<AppointmentModel>> getAppointments(
    DateTime from,
    DateTime to,
  ) async {
    try {
      final response = await apiClient.dio.get(
        '/appointments',
        queryParameters: {
          'from': from.toIso8601String(),
          'to': to.toIso8601String(),
        },
      );
      final list = response.data as List<dynamic>;
      return list.map((json) => AppointmentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? 'Erro ao buscar agendamentos.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar agendamentos: $e');
    }
  }

  @override
  Future<AppointmentModel> createAppointment(Appointment appointment) async {
    try {
      final body = AppointmentModel(
        id: appointment.id,
        patientName: appointment.patientName,
        type: appointment.type,
        date: appointment.date,
        time: appointment.time,
        endTime: appointment.endTime,
        status: appointment.status,
        evaluationNote: appointment.evaluationNote,
      ).toJson();
      final response = await apiClient.dio.post('/appointments', data: body);
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
      final body = AppointmentModel(
        id: appointment.id,
        patientName: appointment.patientName,
        type: appointment.type,
        date: appointment.date,
        time: appointment.time,
        endTime: appointment.endTime,
        status: appointment.status,
        evaluationNote: appointment.evaluationNote,
      ).toJson();
      final response = await apiClient.dio.put(
        '/appointments/${appointment.id}',
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
      await apiClient.dio.delete('/appointments/$id');
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ?? 'Erro ao excluir agendamento.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido ao excluir agendamento: $e');
    }
  }

  @override
  Future<List<String>> getAvailablePatients() async {
    try {
      final response = await apiClient.dio.get('/patients/names');
      final list = response.data as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data?['message'] ??
          'Erro ao buscar pacientes disponíveis.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar pacientes: $e');
    }
  }
}

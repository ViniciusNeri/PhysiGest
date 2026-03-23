import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../models/dashboard_summary_model.dart';

abstract class IDashboardRemoteDataSource {
  Future<DashboardSummaryModel> getSummary();
}

@LazySingleton(as: IDashboardRemoteDataSource)
class DashboardRemoteDataSource implements IDashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSource(this.apiClient);

  @override
  Future<DashboardSummaryModel> getSummary() async {
    try {
      final response = await apiClient.dio.get('/dashboard/summary');
      return DashboardSummaryModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Erro ao carregar dados do dashboard.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido ao carregar dashboard: $e');
    }
  }
}

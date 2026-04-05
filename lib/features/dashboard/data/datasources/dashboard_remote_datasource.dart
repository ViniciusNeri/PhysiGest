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
      final response = await apiClient.dio.get('/dashboard');
      return DashboardSummaryModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}

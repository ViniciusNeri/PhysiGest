import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../models/financial_models.dart';

abstract class IFinancialRemoteDataSource {
  Future<Map<String, dynamic>> getConsolidatedData(String userId, int month, int year);
  Future<TransactionModel> createTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id, String source);
}

@LazySingleton(as: IFinancialRemoteDataSource)
class FinancialRemoteDataSource implements IFinancialRemoteDataSource {
  final ApiClient apiClient;

  FinancialRemoteDataSource(this.apiClient);

  @override
  Future<Map<String, dynamic>> getConsolidatedData(
    String userId,
    int month,
    int year,
  ) async {
    try {
      final response = await apiClient.dio.get(
        '/financials/consolidated',
        queryParameters: {
          'userId': userId,
          'month': month,
          'year': year,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  @override
  Future<TransactionModel> createTransaction(
    TransactionModel transaction,
  ) async {
    try {
      final response = await apiClient.dio.post(
        '/financials',
        data: transaction.toJson(),
      );
      return TransactionModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id, String source) async {
    try {
      final queryParams = source == 'patient' ? {'source': 'patient'} : null;
      await apiClient.dio.delete(
        '/financials/$id',
        queryParameters: queryParams,
      );
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}

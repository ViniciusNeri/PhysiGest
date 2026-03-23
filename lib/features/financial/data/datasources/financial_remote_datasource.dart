import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../models/financial_models.dart';

abstract class IFinancialRemoteDataSource {
  Future<List<TransactionModel>> getTransactions(String month, String year);
  Future<FinancialSummaryModel> getSummary(String month, String year);
  Future<TransactionModel> createTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
}

@LazySingleton(as: IFinancialRemoteDataSource)
class FinancialRemoteDataSource implements IFinancialRemoteDataSource {
  final ApiClient apiClient;

  FinancialRemoteDataSource(this.apiClient);

  @override
  Future<List<TransactionModel>> getTransactions(String month, String year) async {
    try {
      final response = await apiClient.dio.get(
        '/financial/transactions',
        queryParameters: {'month': month, 'year': year},
      );
      final list = response.data as List<dynamic>;
      return list.map((json) => TransactionModel.fromJson(json)).toList();
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Erro ao buscar transações.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar transações: $e');
    }
  }

  @override
  Future<FinancialSummaryModel> getSummary(String month, String year) async {
    try {
      final response = await apiClient.dio.get(
        '/financial/summary',
        queryParameters: {'month': month, 'year': year},
      );
      return FinancialSummaryModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Erro ao buscar resumo financeiro.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar resumo financeiro: $e');
    }
  }

  @override
  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    try {
      final response = await apiClient.dio.post(
        '/financial/transactions',
        data: transaction.toJson(),
      );
      return TransactionModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Erro ao criar transação.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido ao criar transação: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await apiClient.dio.delete('/financial/transactions/$id');
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'Erro ao excluir transação.';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Erro desconhecido ao excluir transação: $e');
    }
  }
}

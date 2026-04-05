import 'package:injectable/injectable.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/financial_summary.dart';
import '../../domain/repositories/i_financial_repository.dart';
import '../datasources/financial_remote_datasource.dart';
import '../models/financial_models.dart';

@LazySingleton(as: IFinancialRepository)
class FinancialRepositoryImpl implements IFinancialRepository {
  final IFinancialRemoteDataSource remoteDataSource;

  FinancialRepositoryImpl(this.remoteDataSource);

  @override
  Future<(FinancialSummary, List<Transaction>)> getConsolidatedData(
    String userId,
    int month,
    int year,
  ) async {
    final data = await remoteDataSource.getConsolidatedData(userId, month, year);
    
    final summary = FinancialSummaryModel.fromJson(data);
    
    final cashFlow = data['cashFlow'] as List<dynamic>? ?? [];
    final transactions = cashFlow
        .map((json) => TransactionModel.fromJson(json))
        .toList();
        
    return (summary, transactions);
  }

  @override
  Future<Transaction> createTransaction(Transaction transaction) async {
    final model = TransactionModel(
      id: transaction.id,
      titulo: transaction.titulo,
      subtitulo: transaction.subtitulo,
      valor: transaction.valor,
      isExpense: transaction.isExpense,
      data: transaction.data,
      paymentMethod: transaction.paymentMethod,
      patientId: transaction.patientId,
      patientName: transaction.patientName,
      source: transaction.source,
      type: transaction.type,
      status: transaction.status,
      category: transaction.category,
      expenseType: transaction.expenseType,
      description: transaction.description,
      userId: transaction.userId,
    );
    return await remoteDataSource.createTransaction(model);
  }

  @override
  Future<void> deleteTransaction(String id, String source) async {
    return await remoteDataSource.deleteTransaction(id, source);
  }
}

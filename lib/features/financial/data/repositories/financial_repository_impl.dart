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
  Future<List<Transaction>> getTransactions(String month, String year) async {
    return await remoteDataSource.getTransactions(month, year);
  }

  @override
  Future<FinancialSummary> getSummary(String month, String year) async {
    return await remoteDataSource.getSummary(month, year);
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
    );
    return await remoteDataSource.createTransaction(model);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    return await remoteDataSource.deleteTransaction(id);
  }
}

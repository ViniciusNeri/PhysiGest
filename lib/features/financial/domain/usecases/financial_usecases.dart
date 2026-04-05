import 'package:injectable/injectable.dart';
import '../entities/transaction.dart';
import '../entities/financial_summary.dart';
import '../repositories/i_financial_repository.dart';

@lazySingleton
class GetConsolidatedFinancialDataUseCase {
  final IFinancialRepository repository;
  GetConsolidatedFinancialDataUseCase(this.repository);
  Future<(FinancialSummary, List<Transaction>)> call(String userId, int month, int year) =>
      repository.getConsolidatedData(userId, month, year);
}

@lazySingleton
class CreateTransactionUseCase {
  final IFinancialRepository repository;
  CreateTransactionUseCase(this.repository);
  Future<Transaction> call(Transaction transaction) =>
      repository.createTransaction(transaction);
}

@lazySingleton
class DeleteTransactionUseCase {
  final IFinancialRepository repository;
  DeleteTransactionUseCase(this.repository);
  Future<void> call(String id, String source) => repository.deleteTransaction(id, source);
}

import 'package:injectable/injectable.dart';
import '../entities/transaction.dart';
import '../entities/financial_summary.dart';
import '../repositories/i_financial_repository.dart';

@lazySingleton
class GetTransactionsUseCase {
  final IFinancialRepository repository;
  GetTransactionsUseCase(this.repository);
  Future<List<Transaction>> call(String month, String year) =>
      repository.getTransactions(month, year);
}

@lazySingleton
class GetFinancialSummaryUseCase {
  final IFinancialRepository repository;
  GetFinancialSummaryUseCase(this.repository);
  Future<FinancialSummary> call(String month, String year) =>
      repository.getSummary(month, year);
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
  Future<void> call(String id) => repository.deleteTransaction(id);
}

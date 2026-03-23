import '../../domain/entities/transaction.dart';
import '../../domain/entities/financial_summary.dart';

abstract class IFinancialRepository {
  Future<List<Transaction>> getTransactions(String month, String year);
  Future<FinancialSummary> getSummary(String month, String year);
  Future<Transaction> createTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
}

import '../../domain/entities/transaction.dart';
import '../../domain/entities/financial_summary.dart';

abstract class IFinancialRepository {
  Future<(FinancialSummary, List<Transaction>)> getConsolidatedData(String userId, int month, int year);
  Future<Transaction> createTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id, String source);
}

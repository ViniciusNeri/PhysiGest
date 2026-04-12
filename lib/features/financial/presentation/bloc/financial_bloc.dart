import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:physigest/core/storage/local_storage.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/financial_usecases.dart';
import 'financial_event.dart';
import 'financial_state.dart';

@injectable
class FinancialBloc extends Bloc<FinancialEvent, FinancialState> {
  final GetConsolidatedFinancialDataUseCase _getConsolidatedData;
  final CreateTransactionUseCase _createTransaction;
  final DeleteTransactionUseCase _deleteTransaction;
  final LocalStorage _storage;

  FinancialBloc(
    this._getConsolidatedData,
    this._createTransaction,
    this._deleteTransaction,
    this._storage,
  ) : super(const FinancialState()) {
    on<LoadFinancialData>(_onLoadFinancialData);
    on<AddTransaction>(_onAddTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<UpdateDateFilter>(_onUpdateDateFilter);
    on<ClearFinancialMessage>((event, emit) {
      emit(state.copyWith(clearMessage: true));
    });
  }

  Future<void> _onLoadFinancialData(
    LoadFinancialData event,
    Emitter<FinancialState> emit,
  ) async {
    try {
      emit(state.copyWith(status: FinancialStatus.loading, clearMessage: true));

      final user = await _storage.getUser();
      if (user == null) {
        emit(state.copyWith(status: FinancialStatus.failure, errorMessage: "Usuário não autenticado."));
        return;
      }

      final now = DateTime.now();
      final month = now.month;
      final year = now.year;

      final (summary, transactions) = await _getConsolidatedData(
        user.id,
        month,
        year,
      );

      emit(
        state.copyWith(
          status: FinancialStatus.success,
          faturamentoTotal: summary.faturamentoTotal,
          contasReceber: summary.contasReceber,
          despesasFixas: summary.despesasFixas,
          lucroLiquido: summary.lucroLiquido,
          incomeByMethod: summary.incomeByMethod,
          expenseByMethod: summary.expenseByMethod,
          yearlyRevenue: summary.yearlyRevenue,
          yearlyExpenses: summary.yearlyExpenses,
          transacoes: transactions,
          selectedMonth: month,
          selectedYear: year,
        ),
      );
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(state.copyWith(status: FinancialStatus.failure, errorMessage: msg));
    }
  }

  Future<void> _onUpdateDateFilter(
    UpdateDateFilter event,
    Emitter<FinancialState> emit,
  ) async {
    try {
      final user = await _storage.getUser();
      if (user == null) return;

      emit(state.copyWith(status: FinancialStatus.loading, clearMessage: true));

      final (summary, transactions) = await _getConsolidatedData(
        user.id,
        event.month,
        event.year,
      );

      emit(
        state.copyWith(
          status: FinancialStatus.success,
          faturamentoTotal: summary.faturamentoTotal,
          contasReceber: summary.contasReceber,
          despesasFixas: summary.despesasFixas,
          lucroLiquido: summary.lucroLiquido,
          incomeByMethod: summary.incomeByMethod,
          expenseByMethod: summary.expenseByMethod,
          yearlyRevenue: summary.yearlyRevenue,
          yearlyExpenses: summary.yearlyExpenses,
          transacoes: transactions,
          selectedMonth: event.month,
          selectedYear: event.year,
        ),
      );
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(state.copyWith(status: FinancialStatus.failure, errorMessage: msg));
    }
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<FinancialState> emit,
  ) async {
    try {
      final user = await _storage.getUser();
      if (user == null) return;

      emit(state.copyWith(status: FinancialStatus.loading, clearMessage: true));

      final data = event.transaction;
      final type = data['type'] == 'revenue' ? 'income' : 'expense';
      final amount = (data['amount'] as num).toDouble();
      final now = DateTime.now();
      
      final transaction = Transaction(
        id: '', 
        titulo: data['description'] ?? '',
        subtitulo: '',
        valor: amount,
        isExpense: type == 'expense',
        data: now.toIso8601String(),
        paymentMethod: data['paymentMethod'] ?? 'cash',
        patientId: data['patientId'],
        type: type,
        status: 'paid', 
        category: (data['patientId'] != null) ? 'Sessão' : (data['category'] ?? 'Outros'),
        expenseType: data['expenseType'],
        description: data['description'] ?? '',
        userId: user.id,
      );

      await _createTransaction(transaction);
      
      emit(state.copyWith(
        status: FinancialStatus.success,
        successMessage: 'Transação adicionada com sucesso!',
      ));

      add(UpdateDateFilter(state.selectedMonth, state.selectedYear));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(state.copyWith(status: FinancialStatus.failure, errorMessage: msg));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<FinancialState> emit,
  ) async {
    try {
      emit(state.copyWith(status: FinancialStatus.loading, clearMessage: true));
      await _deleteTransaction(event.id, event.source);
      
      emit(state.copyWith(
        status: FinancialStatus.success,
        successMessage: 'Transação removida com sucesso!',
      ));
      
      add(UpdateDateFilter(state.selectedMonth, state.selectedYear));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(state.copyWith(status: FinancialStatus.failure, errorMessage: msg));
    }
  }
}


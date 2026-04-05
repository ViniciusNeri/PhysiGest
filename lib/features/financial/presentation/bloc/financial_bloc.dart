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
  ) : super(FinancialLoading()) {
    on<LoadFinancialData>(_onLoadFinancialData);
    on<AddTransaction>(_onAddTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<UpdateDateFilter>(_onUpdateDateFilter);
  }

  Future<void> _onLoadFinancialData(
    LoadFinancialData event,
    Emitter<FinancialState> emit,
  ) async {
    try {
      emit(FinancialLoading());

      final user = await _storage.getUser();
      if (user == null) {
        emit(const FinancialError("Usuário não autenticado."));
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
        FinancialLoaded(
          faturamentoTotal: summary.faturamentoTotal,
          contasReceber: summary.contasReceber,
          despesasFixas: summary.despesasFixas,
          lucroLiquido: summary.lucroLiquido,
          incomeByMethod: summary.incomeByMethod,
          expenseByMethod: summary.expenseByMethod,
          transacoes: transactions,
          selectedMonth: month,
          selectedYear: year,
        ),
      );
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(FinancialError(msg));
    }
  }

  Future<void> _onUpdateDateFilter(
    UpdateDateFilter event,
    Emitter<FinancialState> emit,
  ) async {
    try {
      final user = await _storage.getUser();
      if (user == null) return;

      emit(FinancialLoading());

      final (summary, transactions) = await _getConsolidatedData(
        user.id,
        event.month,
        event.year,
      );

      emit(
        FinancialLoaded(
          faturamentoTotal: summary.faturamentoTotal,
          contasReceber: summary.contasReceber,
          despesasFixas: summary.despesasFixas,
          lucroLiquido: summary.lucroLiquido,
          incomeByMethod: summary.incomeByMethod,
          expenseByMethod: summary.expenseByMethod,
          transacoes: transactions,
          selectedMonth: event.month,
          selectedYear: event.year,
        ),
      );
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(FinancialError(msg));
    }
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<FinancialState> emit,
  ) async {
    try {
      final user = await _storage.getUser();
      if (user == null) return;

      final data = event.transaction;
      final type = data['type'] == 'revenue' ? 'income' : 'expense';
      final amount = (data['amount'] as num).toDouble();
      final now = DateTime.now();
      
      // Criar a entidade para a API
      final transaction = Transaction(
        id: '', // API vai gerar
        titulo: data['description'] ?? '',
        subtitulo: '',
        valor: amount,
        isExpense: type == 'expense',
        data: now.toIso8601String(),
        paymentMethod: data['paymentMethod'] ?? 'cash',
        patientId: data['patientId'],
        type: type,
        status: 'paid', // Confirmado pelo usuário
        category: (data['patientId'] != null) ? 'Sessão' : (data['category'] ?? 'Outros'),
        expenseType: data['expenseType'],
        description: data['description'] ?? '',
        userId: user.id,
      );

      await _createTransaction(transaction);

      // Recarregar os dados após criação
      if (state is FinancialLoaded) {
        final current = state as FinancialLoaded;
        add(UpdateDateFilter(current.selectedMonth, current.selectedYear));
      } else {
        add(LoadFinancialData());
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(FinancialError(msg));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<FinancialState> emit,
  ) async {
    if (state is FinancialLoaded) {
      final current = state as FinancialLoaded;
      try {
        await _deleteTransaction(event.id, event.source);
        add(UpdateDateFilter(current.selectedMonth, current.selectedYear));
      } catch (e) {
        final msg = e.toString().replaceAll('Exception: ', '');
        emit(FinancialError(msg));
      }
    }
  }
}


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'financial_event.dart';
import 'financial_state.dart';

@injectable // Se estiver usando o injectable para gerar o injection.config
class FinancialBloc extends Bloc<FinancialEvent, FinancialState> {
  FinancialBloc() : super(FinancialLoading()) {
    on<LoadFinancialData>(_onLoadFinancialData);
  }

  Future<void> _onLoadFinancialData(
    LoadFinancialData event,
    Emitter<FinancialState> emit,
  ) async {
    try {
      emit(FinancialLoading());

      // Simulando chamada de API
      await Future.delayed(const Duration(seconds: 1));

      // Mock de dados financeiros
      final transacoesMock = [
        {'titulo': 'Sessão: Ana Paula', 'subtitulo': 'Particular (Pix)', 'valor': 150.0, 'isExpense': false, 'data': '26 Out'},
        {'titulo': 'Fornecedor de Luvas', 'subtitulo': 'Despesa Variável', 'valor': 80.0, 'isExpense': true, 'data': '25 Out'},
        {'titulo': 'Sessão: Marcos Vinicius', 'subtitulo': 'Convênio Unimed', 'valor': 120.0, 'isExpense': false, 'data': '25 Out'},
        {'titulo': 'Aluguel Clínica', 'subtitulo': 'Despesa Fixa', 'valor': 1200.0, 'isExpense': true, 'data': '20 Out'},
      ];

      emit(FinancialLoaded(
        faturamentoTotal: 12450.00,
        contasReceber: 2180.00,
        despesasFixas: 3200.00,
        lucroLiquido: 9250.00,
        transacoes: transacoesMock,
      ));
    } catch (e) {
      emit(const FinancialError("Erro ao carregar dados financeiros."));
    }
  }
}
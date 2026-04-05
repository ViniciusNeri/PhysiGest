import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/core/utils/currency_formatter.dart';
import 'package:physigest/core/widgets/side_menu.dart';
// Nota: Você precisará criar o FinancialBloc ou adaptar o DashboardBloc para prover estes dados
import 'package:physigest/features/financial/presentation/bloc/financial_bloc.dart';
import 'package:physigest/features/financial/presentation/bloc/financial_event.dart';
import 'package:physigest/features/financial/presentation/bloc/financial_state.dart';
import 'package:physigest/features/financial/presentation/widgets/add_transaction_dialog.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_bloc.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_event.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_bloc.dart';
import 'package:physigest/core/widgets/app_error_view.dart';

class FinancialScreen extends StatelessWidget {
  const FinancialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<FinancialBloc>()..add(const LoadFinancialData()),
        ),
        BlocProvider(
          create: (_) => getIt<PatientBloc>()..add(LoadPatients()),
        ),
      ],
      child: const FinancialView(),
    );
  }
}

class FinancialView extends StatefulWidget {
  const FinancialView({super.key});

  // Cores do padrão PhysiGest
  static const Color azulPetroleo = Color(0xFF004D4D);
  static const Color roxoClaro = Color(0xFF9370DB);

  @override
  State<FinancialView> createState() => _FinancialViewState();
}

class _FinancialViewState extends State<FinancialView> {
  @override
  void initState() {
    super.initState();
    context.read<FinancialBloc>().add(LoadFinancialData());
  }  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          'Financeiro',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.visibility_outlined,
              color: FinancialView.azulPetroleo,
            ),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const SideMenu(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showGeneralDialog<Map<String, dynamic>>(
            context: context,
            barrierDismissible: true,
            barrierLabel: '',
            barrierColor: Colors.black.withValues(alpha: 0.4),
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (dialogContext, anim1, anim2) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: context.read<FinancialBloc>()),
                  BlocProvider.value(value: context.read<PatientBloc>()),
                  BlocProvider.value(value: context.read<SettingsBloc>()),
                ],
                child: const Center(child: AddTransactionDialog()),
              );
            },
            transitionBuilder: (context, anim1, anim2, child) {
              return ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
                ),
                child: FadeTransition(opacity: anim1, child: child),
              );
            },
          );

          if (result != null && context.mounted) {
            context.read<FinancialBloc>().add(AddTransaction(result));
          }
        },
        backgroundColor: FinancialView.roxoClaro,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: BlocListener<FinancialBloc, FinancialState>(
          listener: (context, state) {
            if (state is FinancialError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red.shade800,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          child: BlocBuilder<FinancialBloc, FinancialState>(
            builder: (context, state) {
              if (state is FinancialLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is FinancialLoaded) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Gestão de Caixa',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Faturamento, despesas e fluxo de caixa',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildMonthYearSelector(context, state),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // CARDS DE RESUMO FINANCEIRO
                          const Text(
                            'MÉTRICAS DO MÊS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),

                          GridView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              mainAxisExtent: 180,
                            ),
                            children: [
                              _FinancialSummaryCard(
                                title: 'Faturamento Total',
                                subtitle: 'Total bruto recebido no mês',
                                value: CurrencyFormatter.format(state.faturamentoTotal),
                                iconText: '💰',
                                color: FinancialView.azulPetroleo,
                              ),
                              _FinancialSummaryCard(
                                title: 'Contas a Receber',
                                subtitle: 'Sessões realizadas não pagas',
                                value: CurrencyFormatter.format(state.contasReceber),
                                iconText: '⏳',
                                color: FinancialView.roxoClaro,
                              ),
                              _FinancialSummaryCard(
                                title: 'Despesas',
                                subtitle: 'Aluguel, luz e materiais',
                                value: CurrencyFormatter.format(state.despesasFixas),
                                iconText: '📉',
                                color: const Color(0xFFFF7A00),
                              ),
                              _FinancialSummaryCard(
                                title: 'Lucro Líquido',
                                subtitle: 'O que sobra após as despesas',
                                value: CurrencyFormatter.format(state.lucroLiquido),
                                iconText: '📈',
                                color: const Color(0xFF10B981),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // DETALHAMENTO POR FORMA DE PAGAMENTO
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'RECEBIMENTOS POR FORMA',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _FinancialBreakdownCard(
                                      backgroundColor: const Color(0xFFF0FDF4),
                                      items: state.incomeByMethod.entries.map((e) {
                                        return _BreakdownItem(
                                          _formatMethodLabel(e.key),
                                          e.value,
                                          _getMethodColor(e.key),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'DESPESAS POR FORMA',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _FinancialBreakdownCard(
                                      backgroundColor: const Color(0xFFFEF2F2),
                                      items: state.expenseByMethod.entries.map((e) {
                                        return _BreakdownItem(
                                          _formatMethodLabel(e.key),
                                          e.value,
                                          _getMethodColor(e.key),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // LISTA DE LANÇAMENTOS
                          _RecentTransactionsCard(state: state),
                        ],
                      ),
                    ),
                  ),
                );
              } else if (state is FinancialError) {
                return AppErrorView(
                  message: state.message,
                  onRetry: () => context.read<FinancialBloc>().add(LoadFinancialData()),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMonthYearSelector(BuildContext context, FinancialLoaded state) {
    final months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - 2 + index);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<int>(
            value: state.selectedMonth,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            items: List.generate(12, (index) {
              return DropdownMenuItem(
                value: index + 1,
                child: Text(
                  months[index],
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              );
            }),
            onChanged: (val) {
              if (val != null) {
                context.read<FinancialBloc>().add(UpdateDateFilter(val, state.selectedYear));
              }
            },
          ),
          const SizedBox(
            height: 20,
            child: VerticalDivider(width: 16, thickness: 1, color: Colors.black12),
          ),
          DropdownButton<int>(
            value: state.selectedYear,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            items: years.map((y) {
              return DropdownMenuItem(
                value: y,
                child: Text(
                  y.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                context.read<FinancialBloc>().add(UpdateDateFilter(state.selectedMonth, val));
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatMethodLabel(String key) {
    switch (key.toLowerCase()) {
      case 'pix': return 'Pix';
      case 'credit_card': return 'Cartão de Crédito';
      case 'debit_card': return 'Cartão de Débito';
      case 'cash': return 'Dinheiro';
      case 'bank_transfer': return 'Transferência';
      case 'boleto': return 'Boleto';
      default: return key.replaceAll('_', ' ');
    }
  }

  Color _getMethodColor(String key) {
    switch (key.toLowerCase()) {
      case 'pix': return const Color(0xFF10B981);
      case 'credit_card': return const Color(0xFF6366F1);
      case 'cash': return const Color(0xFFF59E0B);
      default: return const Color(0xFF94A3B8);
    }
  }
}

class _FinancialSummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String iconText;
  final Color color;

  const _FinancialSummaryCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.iconText,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(iconText, style: const TextStyle(fontSize: 20)),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FinancialBreakdownCard extends StatelessWidget {
  final List<_BreakdownItem> items;
  final Color backgroundColor;

  const _FinancialBreakdownCard({
    required this.items,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: backgroundColor == Colors.white 
            ? Colors.grey.shade100 
            : backgroundColor.withValues(alpha: 0.5), 
          width: 1.5
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              _buildRow(item.label, item.value, item.color),
              if (index < items.length - 1)
                const Divider(height: 24, thickness: 0.5),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRow(String label, double value, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          CurrencyFormatter.format(value),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

class _BreakdownItem {
  final String label;
  final double value;
  final Color color;

  const _BreakdownItem(this.label, this.value, this.color);
}

class _RecentTransactionsCard extends StatelessWidget {
  final FinancialLoaded state;

  const _RecentTransactionsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Fluxo de Caixa Recente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.transacoes.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: Colors.grey.shade50),
            itemBuilder: (context, index) {
              final transacao = state.transacoes[index];
              final isExpense = transacao.isExpense;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isExpense
                      ? Colors.red.shade50
                      : FinancialView.azulPetroleo.withAlpha(25),
                  child: Icon(
                    isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isExpense ? Colors.red : FinancialView.azulPetroleo,
                    size: 18,
                  ),
                ),
                title: Text(transacao.titulo),
                subtitle: Text(
                  '${_formatDate(transacao.data)} • ${transacao.subtitulo}${transacao.isExpense && transacao.expenseType != null ? " • ${_translateExpenseType(transacao.expenseType!)}" : ""}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isExpense ? '- ${CurrencyFormatter.format(transacao.valor)}' : '+ ${CurrencyFormatter.format(transacao.valor)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isExpense ? Colors.red : FinancialView.azulPetroleo,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20),
                      onPressed: () => _confirmDelete(context, transacao.id, transacao.source),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return isoDate.split('T')[0];
    }
  }

  String _translateExpenseType(String type) {
    switch (type.toLowerCase()) {
      case 'fixed': return 'Fixa';
      case 'variable': return 'Variável';
      default: return type;
    }
  }

  void _confirmDelete(BuildContext context, String id, String source) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir Registro?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<FinancialBloc>().add(DeleteTransaction(id, source));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}



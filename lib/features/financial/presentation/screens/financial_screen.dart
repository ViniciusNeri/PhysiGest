import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/core/theme/app_theme.dart';
import 'package:physigest/core/widgets/side_menu.dart';
// Nota: Você precisará criar o FinancialBloc ou adaptar o DashboardBloc para prover estes dados
import 'package:physigest/features/financial/presentation/bloc/financial_bloc.dart';
import 'package:physigest/features/financial/presentation/bloc/financial_event.dart';
import 'package:physigest/features/financial/presentation/bloc/financial_state.dart';
import 'package:physigest/features/financial/presentation/widgets/add_transaction_dialog.dart';

class FinancialScreen extends StatelessWidget {
  const FinancialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FinancialBloc>()..add(const LoadFinancialData()),
      child: const FinancialView(),
    );
  }
}

class FinancialView extends StatelessWidget {
  const FinancialView({super.key});

  // Cores do padrão PhysiGest
  static const Color azulPetroleo = Color(0xFF004D4D);
  static const Color roxoClaro = Color(0xFF9370DB);

  @override
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
            icon: const Icon(Icons.visibility_outlined, color: azulPetroleo),
            onPressed: () {}, // Funcionalidade para ocultar valores sensíveis
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
            barrierColor: Colors.black.withOpacity(0.4),
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (context, anim1, anim2) {
              return const Center(
                child: AddTransactionDialog(),
              );
            },
            transitionBuilder: (context, anim1, anim2, child) {
              return ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0)
                    .animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutBack)),
                child: FadeTransition(
                  opacity: anim1,
                  child: child,
                ),
              );
            },
          );

          if (result != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                content: Text('Lançamento salvo: R\$ ${result['amount']} - ${result['description']}'),
                backgroundColor: FinancialView.azulPetroleo,
              ),
            );
            // Aqui despacharemos o Evento para o FinancialBloc posteriormente
            // context.read<FinancialBloc>().add(AddTransactionEvent(result));
          }
        },
        backgroundColor: roxoClaro,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
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
                        const Text(
                          'Gestão de Caixa',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Controle de faturamento, despesas e repasses',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 32),
                        
                        // CARDS DE RESUMO FINANCEIRO
                        const Text(
                          'MÉTRICAS DO MÊS',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1.2),
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
                              value: 'R\$ 12.450', // Exemplo: vindo do state
                              iconText: '💰',
                              color: azulPetroleo,
                            ),
                            _FinancialSummaryCard(
                              title: 'Contas a Receber',
                              subtitle: 'Sessões realizadas não pagas',
                              value: 'R\$ 2.180',
                              iconText: '⏳',
                              color: roxoClaro,
                            ),
                            _FinancialSummaryCard(
                              title: 'Despesas Fixas',
                              subtitle: 'Aluguel, luz e materiais',
                              value: 'R\$ 3.200',
                              iconText: '📉',
                              color: const Color(0xFFFF7A00), // Laranja para atenção
                            ),
                            _FinancialSummaryCard(
                              title: 'Lucro Líquido',
                              subtitle: 'O que sobra após as despesas',
                              value: 'R\$ 9.250',
                              iconText: '📈',
                              color: const Color(0xFF10B981), // Verde para sucesso
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // LISTA DE LANÇAMENTOS (Substituindo o calendário)
                        _RecentTransactionsCard(),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
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
        border: Border.all(color: color.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              color: color.withOpacity(0.1),
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

class _RecentTransactionsCard extends StatelessWidget {
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
            itemCount: 4,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade50),
            itemBuilder: (context, index) {
              final isExpense = index % 2 != 0;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isExpense ? Colors.red.shade50 : FinancialView.azulPetroleo.withOpacity(0.1),
                  child: Icon(
                    isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isExpense ? Colors.red : FinancialView.azulPetroleo,
                    size: 18,
                  ),
                ),
                title: Text(isExpense ? 'Fornecedor de Luvas' : 'Sessão: Ana Paula'),
                subtitle: Text(isExpense ? 'Despesa Variável' : 'Particular (Pix)'),
                trailing: Text(
                  isExpense ? '- R\$ 80,00' : '+ R\$ 150,00',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isExpense ? Colors.red : FinancialView.azulPetroleo,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
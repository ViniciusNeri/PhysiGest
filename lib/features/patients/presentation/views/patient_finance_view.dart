import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_bloc.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_event.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_state.dart';
import '../../domain/models/patient.dart';
import 'package:physigest/core/utils/currency_formatter.dart';
import '../bloc/patient_financial_bloc.dart';
import '../bloc/patient_financial_event.dart';
import '../bloc/patient_financial_state.dart';
import '../widgets/payment_action_dialog.dart';

class PatientFinanceView extends StatefulWidget {
  final Patient patient;

  const PatientFinanceView({super.key, required this.patient});

  @override
  State<PatientFinanceView> createState() => _PatientFinanceViewState();
}

class _PatientFinanceViewState extends State<PatientFinanceView> {
  // Definição de Cores
  static const Color textMain = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color bgGrey = Color(0xFFF1F5F9);

  @override
  void initState() {
    super.initState();
    // Garante que as configurações sejam carregadas para ter categorias e
    // métodos de pagamento da API disponíveis quando o diálogo abrir.
    final settingsState = context.read<SettingsBloc>().state;
    if (settingsState is SettingsInitial) {
      context.read<SettingsBloc>().add(LoadSettings());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatientFinancialBloc, PatientFinancialState>(
      listener: (context, state) {
        if (state.status == PatientFinancialStatus.paymentAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Lançamento registrado com sucesso!"),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.status == PatientFinancialStatus.statusUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Pagamento atualizado como PAGO!"),
              backgroundColor: Colors.teal,
            ),
          );
        } else if (state.status == PatientFinancialStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? "Erro ao processar financeiro"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<PatientFinancialBloc, PatientFinancialState>(
        builder: (context, state) {
          if (state.status == PatientFinancialStatus.loading &&
              state.summary == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final summary = state.summary ?? const PatientFinancialSummary();

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 800;

              return Scaffold(
                backgroundColor: bgGrey,
                body: SingleChildScrollView(
                  padding: EdgeInsets.all(isDesktop ? 32 : 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(isDesktop),
                          const SizedBox(height: 32),
                          _buildTopCards(isDesktop, summary),
                          const SizedBox(height: 40),
                          _buildActionCard(context, isDesktop),
                          const SizedBox(height: 40),
                          const Text(
                            "Histórico de Transações",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: textMain,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildHistoryTable(context, summary.payments),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Gestão Financeira",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: textMain,
              ),
            ),
            Text(
              "Controle de saldos e vendas",
              style: TextStyle(color: textSecondary),
            ),
          ],
        ),
        if (isDesktop)
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.receipt_long, color: Colors.white, size: 18),
            label: const Text(
              "GERAR RECIBO",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTopCards(bool isDesktop, PatientFinancialSummary summary) {
    final outstanding = CurrencyFormatter.format(summary.outstandingBalance);
    final totalPaid = CurrencyFormatter.format(summary.totalPaidAmount);

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildTopCard(
              "Saldo Devedor",
              outstanding,
              Icons.warning_amber_rounded,
              Colors.redAccent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTopCard(
              "Sessões Totais",
              summary.totalSessions.toString().padLeft(2, '0'),
              Icons.confirmation_number_outlined,
              Colors.blueAccent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTopCard(
              "Total Já Pago",
              totalPaid,
              Icons.insights_rounded,
              Colors.teal,
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildTopCard(
            "Saldo Devedor",
            outstanding,
            Icons.warning_amber_rounded,
            Colors.redAccent,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTopCard(
                  "Sessões Totais",
                  summary.totalSessions.toString().padLeft(2, '0'),
                  Icons.confirmation_number_outlined,
                  Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTopCard(
                  "Total Já Pago",
                  totalPaid,
                  Icons.insights_rounded,
                  Colors.teal,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildTopCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: textMain,
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2DD4BF).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Registrar Lançamento Avulso",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: textMain,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Insira créditos para pacotes ou sessões avulsas pagas por este paciente.",
            style: TextStyle(color: textSecondary),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: isDesktop ? 300 : double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final settingsState = context.read<SettingsBloc>().state;

                List<String> categories = ['Sessões', 'Avaliação', 'Pacote'];
                List<String> methods = [
                  'Pix',
                  'Cartão de Crédito',
                  'Cartão de Débito',
                  'Dinheiro',
                  'Transferência',
                ];

                if (settingsState is SettingsLoaded) {
                  final activeCats = settingsState.categories
                      .where((c) => c.isActive)
                      .map((c) => c.name)
                      .toSet()
                      .toList();
                  if (activeCats.isNotEmpty) categories = activeCats;

                  final activeMethods = settingsState.paymentMethods
                      .where((m) => m.isActive)
                      .map((m) => m.name)
                      .toSet()
                      .toList();
                  if (activeMethods.isNotEmpty) methods = activeMethods;
                }

                showDialog(
                  context: context,
                  builder: (dlgContext) => PaymentActionDialog(
                    availableCategories: categories,
                    availableMethods: methods,
                    onSave: (payment) {
                      context.read<PatientFinancialBloc>().add(
                            AddFinancialPayment(
                              patientId: widget.patient.id,
                              payment: payment,
                            ),
                          );
                    },
                  ),
                );
              },
              icon: const Icon(Icons.add_card_rounded, color: Colors.white),
              label: const Text(
                "REGISTRAR PAGAMENTO",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2DD4BF),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTable(BuildContext context, List<PatientPayment> payments) {
    if (payments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: const Center(
          child: Text(
            "Nenhuma transação registrada.",
            style: TextStyle(color: textSecondary),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: payments.reversed.map((tx) {
          final color = tx.status == 'paid' ? Colors.green : Colors.orange;
          final isLast = tx == payments.first;

          String displayDate = tx.date;
          try {
            final date = DateTime.parse(tx.date).toLocal();
            displayDate =
                '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
          } catch (_) {}

          return Column(
            children: [
              _buildHistoryRow(
                context,
                tx,
                displayDate,
                CurrencyFormatter.format(tx.amount),
                color,
              ),
              if (!isLast) const Divider(height: 1, color: borderColor),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHistoryRow(
    BuildContext context,
    PatientPayment tx,
    String date,
    String value,
    Color color,
  ) {
    final bool isPending = tx.status == 'pending';
    final String statusLabel = isPending ? 'PENDENTE' : 'PAGO';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: textMain,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '[${tx.category}] - ${tx.totalSessions}x',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: textMain,
                    fontSize: 14,
                  ),
                ),
                if (tx.description.isNotEmpty)
                  Text(
                    tx.description,
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                Text(
                  date,
                  style: const TextStyle(color: textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: textMain,
                ),
              ),
              Text(
                statusLabel,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(width: 16),
            IconButton(
              onPressed: () => _showPaymentMethodDialog(context, tx),
              icon: const Icon(Icons.check_circle_outline),
              color: Colors.teal,
              tooltip: 'Marcar como Pago',
              style: IconButton.styleFrom(
                backgroundColor: Colors.teal.withOpacity(0.1),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showPaymentMethodDialog(BuildContext context, PatientPayment tx) {
    // Capture the Bloc instance before showing the dialog
    final financialBloc = context.read<PatientFinancialBloc>();
    
    final settingsState = context.read<SettingsBloc>().state;
    List<String> methods = ['Pix','Cartão de Crédito','Cartão de Débito','Dinheiro','Transferência' ];
    
    if (settingsState is SettingsLoaded) {
      final activeMethods = settingsState.paymentMethods
          .where((m) => m.isActive)
          .map((m) => m.name)
          .toList();
      if (activeMethods.isNotEmpty) methods = activeMethods;
    }

    showDialog(
      context: context,
      builder: (dlgContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Receber Pagamento",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: textMain,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dlgContext),
                      icon: const Icon(Icons.close, size: 20, color: textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Escolha como o paciente realizou o pagamento:",
                  style: TextStyle(color: textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: methods.map((method) {
                    IconData icon = Icons.payments_outlined;
                    if (method.toLowerCase().contains('pix')) icon = Icons.qr_code_2;
                    if (method.toLowerCase().contains('cartão')) icon = Icons.credit_card;
                    if (method.toLowerCase().contains('dinheiro')) icon = Icons.money;

                    return InkWell(
                      onTap: () {
                        // Map method to API string
                        String mappedMethod = method.toLowerCase();
                        if (method == 'Cartão de Crédito') mappedMethod = 'credit_card';
                        if (method == 'Cartão de Débito') mappedMethod = 'debit_card';
                        if (method == 'Transferência') mappedMethod = 'bank_transfer';
                        if (method == 'Dinheiro') mappedMethod = 'cash';
                        if (method == 'Cheque') mappedMethod = 'check';
                        if (method == 'Outros') mappedMethod = 'other';

                        financialBloc.add(
                          UpdatePaymentStatus(
                            patientId: widget.patient.id,
                            paymentId: tx.id,
                            status: 'paid',
                            paymentMethod: mappedMethod,
                          ),
                        );
                        Navigator.pop(dlgContext);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 170, // Adjust for 2-column feel on small widths
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(icon, size: 20, color: const Color(0xFF7C3AED)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                method,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: textMain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(dlgContext),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "CANCELAR",
                      style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

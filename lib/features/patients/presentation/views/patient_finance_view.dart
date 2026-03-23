// lib/features/patients/presentation/views/patient_finance_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/patient.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_bloc.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_state.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../widgets/payment_action_dialog.dart';

class PatientFinanceView extends StatelessWidget {
  final Patient patient;

  const PatientFinanceView({super.key, required this.patient});

  // Definição de Cores para manter o padrão visual das imagens
  static const Color textMain = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color bgGrey = Color(0xFFF1F5F9);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        return Scaffold(
          backgroundColor:
              bgGrey, // Fundo acinzentado para destacar os cards brancos
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 32 : 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1000,
                ), // Dimensão ideal
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(isDesktop),
                    const SizedBox(height: 32),

                    // Seção de Cards de Saldo
                    if (isDesktop) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTopCard(
                              "Saldo Devedor",
                              "R\$ 350,00",
                              Icons.warning_amber_rounded,
                              Colors.redAccent,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTopCard(
                              "Sessões Restantes",
                              "04",
                              Icons.confirmation_number_outlined,
                              Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTopCard(
                              "Total Investido",
                              "R\$ 4.800",
                              Icons.insights_rounded,
                              Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      _buildTopCard(
                        "Saldo Devedor",
                        "R\$ 350,00",
                        Icons.warning_amber_rounded,
                        Colors.redAccent,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTopCard(
                              "Sessões Restantes",
                              "04",
                              Icons.confirmation_number_outlined,
                              Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTopCard(
                              "Total Investido",
                              "R\$ 4.800",
                              Icons.insights_rounded,
                              Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 40),
                    const SizedBox(height: 40),
                    Container(
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
                                final settingsState = context
                                    .read<SettingsBloc>()
                                    .state;
                                List<String> categories = [
                                  'Sessões',
                                  'Avaliação',
                                  'Pacote',
                                ];
                                if (settingsState is SettingsLoaded) {
                                  final activeCats = settingsState.categories
                                      .where((c) => c.isActive)
                                      .map((c) => c.name)
                                      .toList();
                                  if (activeCats.isNotEmpty)
                                    categories = activeCats;
                                }

                                showDialog(
                                  context: context,
                                  builder: (dlgContext) => PaymentActionDialog(
                                    availableCategories: categories,
                                    onSave: (transaction) {
                                      final updatedList =
                                          List<PaymentTransaction>.from(
                                            patient.financialHistory,
                                          )..add(transaction);
                                      final updatedPatient = patient.copyWith(
                                        financialHistory: updatedList,
                                      );
                                      context.read<PatientBloc>().add(
                                        UpdatePatient(updatedPatient),
                                      );

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Lançamento registrado com sucesso!",
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.add_card_rounded,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "REGISTRAR PAGAMENTO",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2DD4BF),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

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

                    // Tabela de Histórico
                    _buildHistoryTable(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- COMPONENTES AUXILIARES ---

  Widget _buildHeader(bool isDesktop) {
    if (isDesktop) {
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
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Gestão Financeira",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: textMain,
            ),
          ),
          const Text(
            "Controle de saldos e vendas",
            style: TextStyle(color: textSecondary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.receipt_long,
                color: Colors.white,
                size: 18,
              ),
              label: const Text(
                "GERAR RECIBO",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
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

  Widget _buildHistoryTable() {
    if (patient.financialHistory.isEmpty) {
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
        children: patient.financialHistory.reversed.map((tx) {
          final color = tx.status == 'PAGO' ? Colors.green : Colors.orange;
          final isLast = tx == patient.financialHistory.first;

          return Column(
            children: [
              _buildHistoryRow(
                tx.serviceType,
                tx.quantity,
                tx.date,
                "R\$ ${tx.value.toStringAsFixed(2).replaceAll('.', ',')}",
                tx.status,
                color,
                tx.title,
              ),
              if (!isLast) const Divider(height: 1, color: borderColor),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHistoryRow(
    String serviceType,
    int quantity,
    String date,
    String value,
    String status,
    Color color,
    String titleObj,
  ) {
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
                  '[$serviceType] - ${quantity}x',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: textMain,
                    fontSize: 14,
                  ),
                ),
                if (titleObj.isNotEmpty)
                  Text(
                    titleObj,
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
                status,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

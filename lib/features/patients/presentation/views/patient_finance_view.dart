// lib/features/patients/presentation/views/patient_finance_view.dart

import 'package:flutter/material.dart';
import '../../domain/models/patient.dart';

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
    return Scaffold(
      backgroundColor: bgGrey, // Fundo acinzentado para destacar os cards brancos
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000), // Dimensão ideal
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),

                // Seção de Cards de Saldo
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopCard("Saldo Devedor", "R\$ 350,00", Icons.warning_amber_rounded, Colors.redAccent),
                    const SizedBox(width: 16),
                    _buildTopCard("Sessões Restantes", "04", Icons.confirmation_number_outlined, Colors.blueAccent),
                    const SizedBox(width: 16),
                    _buildTopCard("Total Investido", "R\$ 4.800", Icons.insights_rounded, Colors.teal),
                  ],
                ),
                const SizedBox(height: 40),

                const Text(
                  "Pacotes Disponíveis",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textMain),
                ),
                const SizedBox(height: 16),

                // Seção de Pacotes
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPackageCard("Básico", "5 Sessões", "R\$ 750", "R\$ 150/sessão", const Color(0xFF2DD4BF)),
                    const SizedBox(width: 16),
                    _buildPackageCard("Intermediário", "10 Sessões", "R\$ 1.300", "R\$ 130/sessão", const Color(0xFFA78BFA)),
                    const SizedBox(width: 16),
                    _buildPackageCard("Premium", "20 Sessões", "R\$ 2.200", "R\$ 110/sessão", const Color(0xFFF59E0B)),
                  ],
                ),
                const SizedBox(height: 40),

                const Text(
                  "Histórico de Transações",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textMain),
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
  }

  // --- COMPONENTES AUXILIARES ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Gestão Financeira", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textMain)),
            Text("Controle de saldos e vendas", style: TextStyle(color: textSecondary)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.receipt_long, color: Colors.white, size: 18),
          label: const Text("GERAR RECIBO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildTopCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
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
              child: Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textMain)),
            ),
            Text(title, style: const TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(String name, String sessions, String price, String detail, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          children: [
            Text(name, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13)),
            const SizedBox(height: 8),
            Text(sessions, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textMain)),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(price, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textMain)),
            ),
            Text(detail, style: const TextStyle(color: textSecondary, fontSize: 11)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                elevation: 0,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("VENDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildHistoryRow("Pacote Intermediário (10 sessões)", "28 Fev 2026", "R\$ 1.300,00", "PAGO", Colors.green),
          const Divider(height: 1, color: borderColor),
          _buildHistoryRow("Avaliação Clínica Avulsa", "12 Fev 2026", "R\$ 250,00", "PAGO", Colors.green),
          const Divider(height: 1, color: borderColor),
          _buildHistoryRow("Sessão Extra - Liberação", "05 Fev 2026", "R\$ 180,00", "PENDENTE", Colors.orange),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String title, String date, String value, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgGrey, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.shopping_bag_outlined, color: textMain, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: textMain, fontSize: 14)),
                Text(date, style: const TextStyle(color: textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: textMain)),
              Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }
}
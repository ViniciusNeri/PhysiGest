// lib/features/patients/presentation/views/patient_summary_view.dart
import 'package:flutter/material.dart';
import '../../domain/models/patient.dart';

class PatientSummaryView extends StatelessWidget {
  final Patient patient;

  const PatientSummaryView({super.key, required this.patient});

  // CORES PADRÃO PARA MANTER CONSISTÊNCIA
  static const Color primaryGradStart = Color(0xFF2DD4BF); 
  static const Color primaryGradEnd = Color(0xFF0D9488);   
  static const Color secondaryGradStart = Color(0xFFA78BFA); 
  static const Color secondaryGradEnd = Color(0xFF7C3AED);   
  static const Color textMain = Color(0xFF1E293B); 
  static const Color textSecondary = Color(0xFF94A3B8); 

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 32), // Ajustado para não colar no topo
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // COLUNA ESQUERDA (SIDEBAR IGUAL À IMAGEM)
              Expanded(
                flex: 3,
                child: _buildSidebarProfile(),
              ),
              const SizedBox(width: 32),
              // COLUNA DIREITA (CONTEÚDO)
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    _buildPremiumStatsRow(),
                    const SizedBox(height: 32),
                    _buildQuickViewCard(
                      "Última Nota de Evolução", 
                      patient.anamnesis.mainComplaint.isEmpty 
                        ? "Nenhuma observação registrada." 
                        : patient.anamnesis.mainComplaint
                    ),
                    const SizedBox(height: 32),
                    _buildRecentHistoryCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarProfile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          children: [
            // Cabeçalho Colorido (conforme a imagem 1 e 2)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [primaryGradStart, primaryGradEnd]),
              ),
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Text(
                      patient.name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryGradEnd),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    patient.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "34 anos • Feminino", // Aqui você pode calcular a idade depois
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            // Lista de Informações com ícones coloridos (Imagem 1)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _sidebarTile(Icons.phone_android_rounded, "Telefone", patient.phone, const Color(0xFFE0F2FE), Colors.blue),
                  _sidebarTile(Icons.alternate_email_rounded, "E-mail", patient.email, const Color(0xFFFFF7ED), Colors.orange),
                  _sidebarTile(Icons.work_outline_rounded, "Profissão", patient.occupation, const Color(0xFFF0FDFA), Colors.teal),
                  _sidebarTile(Icons.cake_outlined, "Nascimento", "15/05/1985", const Color(0xFFF5F3FF), Colors.purple),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebarTile(IconData icon, String label, String value, Color bg, Color iconCol) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: iconCol, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textMain)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStatsRow() {
    return Row(
      children: [
        _statCard("12", "Total Sessões", Icons.verified_rounded, [primaryGradStart, primaryGradEnd]),
        const SizedBox(width: 16),
        _statCard("0", "Faltas", Icons.do_not_disturb_on_rounded, [Colors.redAccent, Colors.red]),
        const SizedBox(width: 16),
        _statCard("05/03", "Próxima", Icons.event_available_rounded, [const Color(0xFFFBBF24), const Color(0xFFF59E0B)]),
      ],
    );
  }

  Widget _statCard(String val, String label, IconData icon, List<Color> colors) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: colors[1].withOpacity(0.1), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textMain)),
                Text(label, style: const TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickViewCard(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textMain)),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(color: textSecondary, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildRecentHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_rounded, color: textMain, size: 20),
              SizedBox(width: 8),
              Text("Atividades Recentes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          _historyItem("Sessão Realizada", "26 de Fevereiro", Icons.check_circle_rounded, Colors.green),
          _historyItem("Pagamento Recebido", "20 de Fevereiro", Icons.account_balance_wallet_rounded, Colors.blue),
        ],
      ),
    );
  }

  Widget _historyItem(String title, String date, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(date, style: const TextStyle(color: textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
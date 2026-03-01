import 'package:flutter/material.dart';
import '../../domain/models/patient.dart';

class PatientAgendaView extends StatelessWidget {
  final Patient patient;

  const PatientAgendaView({super.key, required this.patient});

  // CORES DO SISTEMA
  static const Color textMain = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color primaryTeal = Color(0xFF0D9488);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho da Agenda
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Agenda do Paciente",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textMain),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    label: const Text("AGENDAR", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Itens da Timeline (Baseado na sua imagem)
              _buildTimelineItem(
                date: "05 Mar",
                time: "14:00",
                title: "Reavaliação",
                status: "AGENDADO",
                color: Colors.orange,
                icon: Icons.event_note_rounded,
              ),
              _buildTimelineItem(
                date: "26 Fev",
                time: "10:30",
                title: "Sessão Fisioterapia",
                status: "CONCLUÍDO",
                color: primaryTeal,
                icon: Icons.check_circle_rounded,
              ),
              _buildTimelineItem(
                date: "19 Fev",
                time: "10:30",
                title: "Sessão Fisioterapia",
                status: "CONCLUÍDO",
                color: primaryTeal,
                icon: Icons.check_circle_rounded,
              ),
              _buildTimelineItem(
                date: "12 Fev",
                time: "09:00",
                title: "Avaliação Inicial",
                status: "CONCLUÍDO",
                color: Colors.purple,
                icon: Icons.assignment_turned_in_rounded,
                isLast: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String date,
    required String time,
    required String title,
    required String status,
    required Color color,
    required IconData icon,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha e Círculo da Esquerda
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6)],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: borderColor,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 24),

          // Card de Conteúdo
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  // Ícone de Status Lateral
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 20),

                  // Info do Atendimento
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textMain),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: textSecondary),
                            const SizedBox(width: 4),
                            Text("$date às $time", style: const TextStyle(color: textSecondary, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Badge de Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
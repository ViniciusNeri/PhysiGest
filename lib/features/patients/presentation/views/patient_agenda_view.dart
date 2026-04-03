import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/features/patients/domain/models/appointment.dart';
import 'package:physigest/features/patients/domain/models/patient.dart';
import 'package:physigest/features/patients/presentation/bloc/agenda_bloc.dart';
import 'package:physigest/features/patients/presentation/bloc/agenda_event.dart';
import 'package:physigest/features/patients/presentation/bloc/agenda_state.dart';

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
    return BlocProvider(
      create: (_) => getIt<AgendaBloc>()..add(LoadAgenda(patient.id)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 800;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 48 : 16),
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
                        Text(
                          "Agenda do Paciente",
                          style: TextStyle(
                            fontSize: isDesktop ? 26 : 22,
                            fontWeight: FontWeight.w900,
                            color: textMain,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                          ),
                          label: isDesktop
                              ? const Text(
                                  "AGENDAR",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(""),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 24 : 16,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // Lista da API
                    BlocBuilder<AgendaBloc, AgendaState>(
                      builder: (context, state) {
                        if (state.status == AgendaStatus.loading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (state.status == AgendaStatus.failure) {
                          return Center(
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  state.errorMessage ?? 'Erro ao carregar agenda.',
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context
                                      .read<AgendaBloc>()
                                      .add(LoadAgenda(patient.id)),
                                  child: const Text('Tentar novamente'),
                                ),
                              ],
                            ),
                          );
                        }
                        if (state.appointments.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      color: textSecondary, size: 64),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Nenhum agendamento encontrado.',
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            for (int i = 0; i < state.appointments.length; i++)
                              _buildTimelineItem(
                                appointment: state.appointments[i],
                                isLast: i == state.appointments.length - 1,
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(Appointment a) {
    switch (a.statusColorKey) {
      case 'teal':
        return primaryTeal;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(Appointment a) {
    switch (a.statusColorKey) {
      case 'teal':
        return Icons.check_circle_rounded;
      case 'orange':
        return Icons.event_note_rounded;
      case 'red':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Widget _buildTimelineItem({
    required Appointment appointment,
    bool isLast = false,
  }) {
    final color = _statusColor(appointment);
    final icon = _statusIcon(appointment);

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
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 6,
                    ),
                  ],
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Ícone de Status Lateral
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
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
                          appointment.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: textMain,
                          ),
                        ),
                        if (appointment.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            appointment.description,
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${appointment.displayDate} às ${appointment.displayTime}",
                              style: const TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Badge de Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      appointment.displayStatus,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/core/theme/app_theme.dart';
import 'package:physigest/core/widgets/side_menu.dart';
import 'package:physigest/features/dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:physigest/features/dashboard/presentation/bloc/dashboard/dashboard_event.dart';
import 'package:physigest/features/dashboard/presentation/bloc/dashboard/dashboard_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DashboardBloc>()..add(const LoadDashboardData()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Cinza bem claro e frio para fundo premium
      appBar: AppBar(
        title: const Text(
          'Início',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      drawer: const SideMenu(),
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DashboardError) {
              return Center(child: Text(state.message));
            } else if (state is DashboardLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(const LoadDashboardData());
                },
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Dashboard',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tela inicial com métricas e calendário semanal interativo',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'CAIXINHAS DE RESUMO',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 16),
                      GridView(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 800
                              ? 4
                              : MediaQuery.of(context).size.width > 600
                                  ? 2
                                  : 1,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          mainAxisExtent: 180, // Aumentado para 180 para evitar overflow
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _SummaryCard(
                            title: 'Atendimentos de Hoje',
                            subtitle: 'Consultas agendadas para hoje',
                            value: state.atendimentosHoje.toString(),
                            iconText: '📅', // Simulating icon with emoji for similar look
                            color: const Color(0xFF9146FF), // Purple
                          ),
                          _SummaryCard(
                            title: 'Mensalidades a Vencer',
                            subtitle: 'Vencimento nos próximos 7 dias',
                            value: state.mensalidadesVencer.toString(),
                            iconText: '💳',
                            color: const Color(0xFFFF7A00), // Orange
                          ),
                          _SummaryCard(
                            title: 'Atendimentos da Semana',
                            subtitle: 'Total de consultas na semana',
                            value: state.atendimentosSemana.toString(),
                            iconText: '📊',
                            color: const Color(0xFF3B82F6), // Blue
                          ),
                          _SummaryCard(
                            title: 'Fichas Vencidas',
                            subtitle: 'Fichas que precisam de atualização',
                            value: state.fichasVencidas.toString(),
                            iconText: '📋',
                            color: const Color(0xFFE11D48), // Red/Pink
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _WeeklyCalendarCard(agendamentos: state.agendamentosSemana),
                    ],
                  ),
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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String iconText;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.iconText,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.85),
            color,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            iconText,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _WeeklyCalendarCard extends StatelessWidget {
  final Map<DateTime, List<String>> agendamentos;

  const _WeeklyCalendarCard({required this.agendamentos});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Calendário Semanal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildDaysHeader(),
                const SizedBox(height: 24),
                _buildAppointmentsList(),
                const SizedBox(height: 24),
                Text(
                  'Horários da semana',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysHeader() {
    final days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final dates = ['24', '25', '26', '27', '28', '29', '30'];
    final activeIndex = 2; // Fixed Qua 26 to match image

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final isActive = index == activeIndex;
        return Column(
          children: [
            Text(
              days[index],
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primaryColor : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  dates[index],
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.black87,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAppointmentsList() {
    // Hardcoded to perfectly match the mockup
    final mockAppointments = [
      {'time': '08:00', 'name': 'Maria Silva', 'type': 'Avaliação Inicial', 'day': 'Seg'},
      {'time': '09:30', 'name': 'João Santos', 'type': 'Retorno', 'day': 'Ter'},
      {'time': '10:00', 'name': 'Ana Costa', 'type': 'Fisioterapia Ortopédica', 'day': 'Qua'},
      {'time': '14:00', 'name': 'Carlos Lima', 'type': 'RPG', 'day': 'Qui'},
      {'time': '15:30', 'name': 'Paula Mendes', 'type': 'Pilates Clínico', 'day': 'Sex'},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mockAppointments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final apt = mockAppointments[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  apt['time']!,
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apt['name']!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      apt['type']!,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                apt['day']!,
                style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}


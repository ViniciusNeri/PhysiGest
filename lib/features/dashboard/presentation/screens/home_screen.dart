import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/core/utils/currency_formatter.dart';
import 'package:physigest/core/widgets/side_menu.dart';
import 'package:physigest/features/dashboard/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:physigest/features/dashboard/presentation/bloc/dashboard/dashboard_event.dart';
import 'package:physigest/features/dashboard/presentation/bloc/dashboard/dashboard_state.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';
import 'package:physigest/features/schedule/presentation/widgets/appointment_action_dialog.dart';
import 'package:physigest/core/storage/local_storage.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_bloc.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_state.dart';
import 'package:intl/intl.dart';
import 'package:physigest/core/widgets/app_error_view.dart';

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

  // Paleta Premium
  static const Color primary = Color(0xFF4F46E5);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF0EA5E9);
  static const Color danger = Color(0xFFEF4444);
  static const Color bg = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 1000;
    final double horizontalPadding = isDesktop ? width * 0.08 : 20.0;
    final String userName = getIt<LocalStorage>().getUserName() ?? "";

    return Scaffold(
      backgroundColor: bg,
      drawer: const SideMenu(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primary, size: 28),
        title: const Text(
          "Painel de Gestão",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          bool showWeekly = true;
          bool showIncome = true;
          bool showPayments = true;
          bool showNext = true;

          if (settingsState is SettingsLoaded) {
            final prefs = settingsState.dashboardPreferences;
            showWeekly = prefs.showWeeklyAppointments;
            showIncome = prefs.showMonthlyIncome;
            showPayments = prefs.showActivePayments;
            showNext = prefs.showNextAppointment;
          }

          return BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              // --- ESTADO DE CARREGAMENTO (SKELETON) ---
              if (state is DashboardLoading) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 32,
                  ),
                  child: _buildSkeletonLoader(width, isDesktop),
                );
              }

              if (state is DashboardError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 60),
                    child: AppErrorView(
                      message: state.message,
                      onRetry: () => context.read<DashboardBloc>().add(const LoadDashboardData()),
                    ),
                  ),
                );
              }

              // --- ESTADO CARREGADO ---
              if (state is DashboardLoaded) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(userName),
                      const SizedBox(height: 32),

                      // Grid de Métricas Coloridas
                      if (showWeekly || showIncome || showPayments)
                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            if (showWeekly)
                              _buildMetricCard(
                                width,
                                "Atendimentos hoje",
                                state.todaysAppointments.length.toString(),
                                Icons.calendar_today,
                                primary,
                              ),
                            _buildMetricCard(
                              width,
                              "Atendimentos na semana",
                              state.weeklyAppointments.toString(),
                              Icons.calendar_month_rounded,
                              warning,
                            ),
                            if (showIncome)
                              _buildMetricCard(
                                width,
                                "Faturamento mês",
                                CurrencyFormatter.format(state.monthlyIncome),
                                Icons.account_balance_wallet,
                                success,
                              ),
                            if (showPayments)
                              _buildMetricCard(
                                width,
                                "Pagamentos pendentes",
                                state.activePayments.toString(),
                                Icons.payment_rounded,
                                danger,
                              ),
                          ],
                        ),

                      if (showWeekly || showIncome || showPayments)
                        const SizedBox(height: 32),

                      // Seção Principal: Agenda e Coluna Lateral
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showWeekly)
                              Expanded(
                                flex: 2,
                                child: _buildAgendaSection(
                                  context,
                                  state.todaysAppointments,
                                ),
                              ),
                            if (showWeekly) const SizedBox(width: 24),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                    _buildQuickActions(),
                                    const SizedBox(height: 24),
                                    _buildNextAppointmentCard(
                                      state.nextAppointment,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (showWeekly) ...[
                              _buildAgendaSection(
                                context,
                                state.todaysAppointments,
                              ),
                              const SizedBox(height: 24),
                            ],
                            _buildQuickActions(),
                            if (showNext) ...[
                              const SizedBox(height: 24),
                              _buildNextAppointmentCard(state.nextAppointment),
                            ],
                          ],
                        ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  // --- COMPONENTES DE UI ---

  Widget _buildHeader(String name) {
    // Vamos pegar apenas o primeiro nome para não quebrar o layout
    final firstName = name.split(' ').first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Olá, $firstName 👋", // Exibe o nome dinâmico
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const Text(
          "Confira o resumo da sua clínica para hoje.",
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    double screenWidth,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    double cardWidth = (screenWidth > 1200)
        ? (screenWidth * 0.84 - 80) / 4
        : (screenWidth > 700 ? (screenWidth - 60) / 2 : screenWidth - 40);
    return Container(
      width: cardWidth,
      height: 120,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(icon, size: 70, color: Colors.white.withValues(alpha: 0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaSection(
    BuildContext context,
    List<Appointment> atendimentosHoje,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Agenda de Hoje",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (atendimentosHoje.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "Nenhum atendimento para hoje.",
                style: TextStyle(color: Colors.black54),
              ),
            )
          else
            ...atendimentosHoje.map(
              (apt) => _buildAppointmentItem(context, apt),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ações Rápidas",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildAnimatedActionCard(
                Icons.person_add_rounded,
                "Paciente",
                primary,
              ),
              _buildAnimatedActionCard(
                Icons.receipt_long_rounded,
                "Receita",
                success,
              ),
              _buildAnimatedActionCard(
                Icons.event_available_rounded,
                "Agenda",
                info,
              ),
              _buildAnimatedActionCard(
                Icons.bar_chart_rounded,
                "Relatório",
                warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedActionCard(IconData icon, String label, Color color) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isPressed = false;
        return GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
          child: AnimatedScale(
            scale: isPressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.1)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextAppointmentCard(Appointment? next) {
    if (next == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black12.withValues(alpha: 0.05)),
        ),
        child: const Center(
          child: Text(
            "Nenhuma próxima consulta",
            style: TextStyle(color: Colors.black45, fontSize: 13),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PRÓXIMA CONSULTA",
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            next.patientName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${next.categoryName ?? next.categoryId ?? 'Consulta'} • ${DateFormat("dd/MM 'às' HH:mm").format(next.startDate)}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  // --- SKELETON LOADER (SHIMMER) ---

  Widget _buildSkeletonLoader(double width, bool isDesktop) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 30,
            width: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 15,
            width: 350,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(4, (i) {
              double cardWidth = (width > 1200)
                  ? (width * 0.84 - 80) / 4
                  : (width > 700 ? (width - 60) / 2 : width - 40);
              return Container(
                width: cardWidth,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }),
          ),
          const SizedBox(height: 40),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(BuildContext context, Appointment apt) {
    IconData statusIcon = Icons.access_time_rounded;
    Color statusColor = warning;

    if (apt.status == 'completed') {
      statusIcon = Icons.check_circle_rounded;
      statusColor = success;
    } else if (apt.status == 'no_show') {
      statusIcon = Icons.cancel_rounded;
      statusColor = Colors.redAccent;
    } else if (apt.status == 'cancelled') {
      statusIcon = Icons.event_busy_rounded;
      statusColor = Colors.orangeAccent;
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (dContext) => AppointmentActionDialog(
            appointment: apt,
            onSave: (updatedApt) {
              context.read<DashboardBloc>().add(
                UpdateDashboardAppointment(updatedApt),
              );
            },
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12.withValues(alpha: 0.05)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat('HH:mm').format(apt.startDate),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      Text(
                        apt.patientName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration:
                              (apt.status == 'cancelled' || apt.status == 'no_show')
                              ? TextDecoration.lineThrough
                              : null,
                          color:
                              (apt.status == 'cancelled' || apt.status == 'no_show')
                              ? Colors.black38
                              : Colors.black87,
                        ),
                      ),
                      Text(
                        '(${apt.categoryName ?? apt.categoryId ?? "Atendimento"})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  if (apt.notes != null && apt.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        apt.notes!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black45,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            Icon(statusIcon, color: statusColor, size: 20),
          ],
        ),
      ),
    );
  }
}

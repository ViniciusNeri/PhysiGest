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
import 'package:physigest/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:physigest/features/schedule/presentation/widgets/appointment_action_dialog.dart';
import 'package:physigest/core/storage/local_storage.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_bloc.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_state.dart';
import 'package:physigest/core/utils/app_alerts.dart';
import 'package:physigest/core/widgets/loading_overlay.dart';
import 'package:intl/intl.dart';
import 'package:physigest/core/widgets/app_error_view.dart';
import 'package:fl_chart/fl_chart.dart';

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

// Paleta Premium
const Color primary = Color(0xFF4F46E5);
const Color success = Color(0xFF10B981);
const Color warning = Color(0xFFF59E0B);
const Color info = Color(0xFF0EA5E9);
const Color danger = Color(0xFFEF4444);
const Color bg = Color(0xFFF8FAFC);

class HomeView extends StatelessWidget {
  const HomeView({super.key});

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
          ),
        ),
      ),      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state.status == DashboardStatus.failure && state.errorMessage != null) {
            AppAlerts.error(context, state.errorMessage!);
          } else if (state.successMessage != null) {
            AppAlerts.success(context, state.successMessage!);
          }
        },
        builder: (context, state) {
          return BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, settingsState) {
              bool showWeekly = true;
              bool showIncome = true;
              bool showPayments = true;
              bool showNext = true;
              bool showBirthdays = true;
              bool showOccupancyGraph = true;

              if (settingsState is SettingsLoaded) {
                final prefs = settingsState.dashboardPreferences;
                showWeekly = prefs.showWeeklyAppointments;
                showIncome = prefs.showMonthlyIncome;
                showPayments = prefs.showActivePayments;
                showNext = prefs.showNextAppointment;
                showBirthdays = prefs.showBirthdays;
                showOccupancyGraph = prefs.showOccupancyGraph;
              }

              // --- ESTADO DE CARREGAMENTO INICIAL (SKELETON) ---
              if (state.status == DashboardStatus.loading && state.todaysAppointments.isEmpty) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 32,
                  ),
                  child: _buildSkeletonLoader(width, isDesktop),
                );
              }

              if (state.status == DashboardStatus.failure && state.todaysAppointments.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 60),
                    child: AppErrorView(
                      message: state.errorMessage ?? "Erro ao carregar dashboard",
                      onRetry: () => context.read<DashboardBloc>().add(const LoadDashboardData()),
                    ),
                  ),
                );
              }

              // --- ESTADO CARREGADO ---
              return LoadingOverlay(
                isLoading: state.status == DashboardStatus.loading && state.todaysAppointments.isNotEmpty,
                message: "Atualizando dados...",
                child: SingleChildScrollView(
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
                                onTap: () => _showPendingPaymentsPopup(context, state.pendingPayments),
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
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  if (showWeekly)
                                    _buildAgendaSection(
                                      context,
                                      state.todaysAppointments,
                                    ),
                                  if (showOccupancyGraph) ...[
                                    const SizedBox(height: 24),
                                    _buildOccupancyChartCard(state.occupancyGraph),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  if (showNext) ...[
                                    const SizedBox(height: 24),
                                    _buildNextAppointmentCard(
                                      state.nextAppointment,
                                    ),
                                  ],
                                  if (showBirthdays) ...[
                                    const SizedBox(height: 24),
                                    _buildBirthdaysCard(state.birthdayList),
                                  ],
                                  if (state.overdueAppointments.isNotEmpty) ...[
                                    const SizedBox(height: 24),
                                    _buildOverdueAppointmentsCard(context, state.overdueAppointments),
                                  ],
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
                            if (showNext) ...[
                              const SizedBox(height: 24),
                              _buildNextAppointmentCard(state.nextAppointment),
                            ],
                            if (showOccupancyGraph) ...[
                              const SizedBox(height: 24),
                              _buildOccupancyChartCard(state.occupancyGraph),
                            ],
                            if (showBirthdays) ...[
                              const SizedBox(height: 24),
                              _buildBirthdaysCard(state.birthdayList),
                            ],
                            if (state.overdueAppointments.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              _buildOverdueAppointmentsCard(context, state.overdueAppointments),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
              );
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
    Color color, {
    VoidCallback? onTap,
  }) {
    double cardWidth = (screenWidth > 1200)
        ? (screenWidth * 0.84 - 80) / 4
        : (screenWidth > 700 ? (screenWidth - 60) / 2 : screenWidth - 40);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
              child:
                  Icon(icon, size: 70, color: Colors.white.withValues(alpha: 0.1)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
      ),
    );
  }


  Widget _buildOccupancyChartCard(Map<int, int> stats) {
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
            "Ocupação por Horário",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 10,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "${value.toInt()}h",
                            style: const TextStyle(color: Colors.grey, fontSize: 10),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: stats.entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.toDouble(),
                        color: info,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthdaysCard(List<BirthdayEntry> birthdays) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D28D9).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Aniversariantes",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Pacientes celebrando este mês",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Icon(Icons.cake_rounded, color: Colors.white.withValues(alpha: 0.3), size: 24),
            ],
          ),
          const SizedBox(height: 24),
          if (birthdays.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Nenhum aniversariante este mês",
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ),
            )
          else
            ...birthdays.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          b.name.isNotEmpty ? b.name[0] : '?',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Dia ${b.day}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.celebration_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildOverdueAppointmentsCard(BuildContext context, List<Appointment> appointments) {
    final list = appointments.take(5).toList(); // Limite visual
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: danger.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: danger.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.history_rounded, color: danger, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Baixa Pendente",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: danger),
                    ),
                    Text(
                      "Agendados em dias passados",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...list.map((apt) => _buildAppointmentItem(context, apt)),
          if (appointments.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  "E mais ${appointments.length - 5} pendentes...",
                  style: const TextStyle(color: Colors.black45, fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ),
            )
        ],
      ),
    );
  }

  void _showPendingPaymentsPopup(BuildContext context, List<PendingPaymentEntry> payments) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "PendingPayments",
      barrierColor: Colors.black.withValues(alpha: 0.15),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 550,
              height: 600,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // HEADER
                  Container(
                    padding: const EdgeInsets.fromLTRB(32, 32, 24, 24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: danger.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.payment_rounded, color: danger),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Pagamentos Pendentes",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                "Total de ${payments.length} faturas pendentes",
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded, color: Colors.black26),
                          splashRadius: 24,
                        ),
                      ],
                    ),
                  ),

                  // SEARCH BAR (Optional UI polish)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Buscar paciente ou fatura...",
                        prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.black26),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // PAYMENTS LIST
                  Expanded(
                    child: payments.isEmpty 
                    ? const Center(
                        child: Text(
                          "Nenhum pagamento pendente no momento.",
                          style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold),
                        ),
                      )
                    : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      physics: const BouncingScrollPhysics(),
                      itemCount: payments.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final payment = payments[index];
                        final dateStr = payment.dueDate != null 
                            ? DateFormat("dd MMM").format(DateTime.parse(payment.dueDate!))
                            : DateFormat("dd MMM").format(DateTime.parse(payment.date));

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.white,
                                child: Text(
                                  payment.patientName.isNotEmpty ? payment.patientName[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: danger,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      payment.patientName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    Text(
                                      "Vencimento: $dateStr",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black38,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(payment.amount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: danger,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: danger.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      "Cobrar",
                                      style: TextStyle(
                                        color: danger,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOutBack,
            )),
            child: child,
          ),
        );
      },
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

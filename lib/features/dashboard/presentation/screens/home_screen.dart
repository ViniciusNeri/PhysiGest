import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:physigest/core/di/injection.dart';
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

  // Paleta Premium
  static const Color primary = Color(0xFF4F46E5);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF0EA5E9);
  static const Color bg = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 1000;
    final double horizontalPadding = isDesktop ? width * 0.08 : 20.0;

    return Scaffold(
      backgroundColor: bg,
      drawer: const SideMenu(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primary, size: 28),
        title: const Text(
          "Painel de Gestão",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          // --- ESTADO DE CARREGAMENTO (SKELETON) ---
          if (state is DashboardLoading) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 32),
              child: _buildSkeletonLoader(width, isDesktop),
            );
          }

          // --- ESTADO CARREGADO ---
          if (state is DashboardLoaded) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  
                  // Grid de Métricas Coloridas
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _buildMetricCard(width, "Atendimentos da semana", state.atendimentosHoje.toString(), Icons.calendar_today, primary),
                      _buildMetricCard(width, "Faturamento mês", "R\$ 4.250", Icons.account_balance_wallet, success),
                      _buildMetricCard(width, "Pacientes ativos", "248", Icons.people_alt, info),
                      _buildMetricCard(width, "Fichas vencidas", state.fichasVencidas.toString(), Icons.warning_rounded, warning),
                    ],
                  ),
                  
                  const SizedBox(height: 32),

                  // Seção Principal: Agenda e Coluna Lateral
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildAgendaSection()),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildQuickActions(),
                            const SizedBox(height: 24),
                            _buildNextAppointmentCard(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // --- COMPONENTES DE UI ---

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Olá, Dra. 👋", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        Text("Confira o resumo da sua clínica para hoje.", style: TextStyle(color: Colors.black54, fontSize: 14)),
      ],
    );
  }

  Widget _buildMetricCard(double screenWidth, String title, String value, IconData icon, Color color) {
    double cardWidth = (screenWidth > 1200) ? (screenWidth * 0.84 - 80) / 4 : (screenWidth - 60) / 2;
    return Container(
      width: cardWidth,
      height: 120,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Stack(
        children: [
          Positioned(right: -10, bottom: -10, child: Icon(icon, size: 70, color: Colors.white.withOpacity(0.1))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Agenda de Hoje", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildAppointmentItem("09:00", "Maria Silva", "Fisioterapia", true),
          _buildAppointmentItem("10:30", "Ricardo Alves", "Pilates", true),
          _buildAppointmentItem("14:00", "Carla Dias", "Avaliação", false),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Ações Rápidas", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildAnimatedActionCard(Icons.person_add_rounded, "Paciente", primary),
              _buildAnimatedActionCard(Icons.receipt_long_rounded, "Receita", success),
              _buildAnimatedActionCard(Icons.event_available_rounded, "Agenda", info),
              _buildAnimatedActionCard(Icons.bar_chart_rounded, "Relatório", warning),
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
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.1)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(height: 6),
                  Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextAppointmentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4338CA)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("PRÓXIMA CONSULTA", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 10)),
          SizedBox(height: 10),
          Text("João Carlos Santos", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Avaliação Funcional • 15:30", style: TextStyle(color: Colors.white70, fontSize: 12)),
          SizedBox(height: 10),
          Align(alignment: Alignment.centerRight, child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16)),
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
          Container(height: 30, width: 250, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 8),
          Container(height: 15, width: 350, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 32),
          Row(
            children: List.generate(4, (i) => Expanded(
              child: Container(height: 120, margin: const EdgeInsets.only(right: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
            )),
          ),
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: Container(height: 300, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)))),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: Column(
                children: [
                  Container(height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
                  const SizedBox(height: 24),
                  Container(height: 140, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
                ],
              )),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(String time, String name, String type, bool isConfirmed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Text(time, style: const TextStyle(fontWeight: FontWeight.w900, color: primary)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(type, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          ])),
          Icon(isConfirmed ? Icons.check_circle_rounded : Icons.pending_rounded, color: isConfirmed ? success : warning, size: 20),
        ],
      ),
    );
  }
}
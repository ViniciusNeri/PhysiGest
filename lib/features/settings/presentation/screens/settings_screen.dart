import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/side_menu.dart';
import '../bloc/settings/settings_bloc.dart';
import '../bloc/settings/settings_event.dart';
import '../bloc/settings/settings_state.dart';
import 'change_password_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(LoadSettings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      drawer: const SideMenu(),
      appBar: AppBar(
        title: const Text(
          'Configurações',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading || state is SettingsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingsError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is SettingsLoaded) {
            return _buildContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, SettingsLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Minha Conta'),
              const SizedBox(height: 16),
              _buildAccountCard(context, state),
              const SizedBox(height: 32),
              _buildSectionTitle('Gerenciamento'),
              const SizedBox(height: 16),
              _buildManagementCard(context),
              const SizedBox(height: 32),
              _buildSectionTitle('Preferências do Dashboard'),
              const SizedBox(height: 16),
              _buildDashboardPreferencesCard(context, state),
              const SizedBox(height: 40), // Spacing at bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF334155),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, SettingsLoaded state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: _buildIconFrame(Icons.email_rounded, Colors.blue),
            title: const Text(
              'Estou logado como',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            subtitle: Text(
              state.userEmail,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: Color(0xFFF1F5F9),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: _buildIconFrame(Icons.password_rounded, Colors.purple),
            title: const Text(
              'Senha de acesso',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                foregroundColor: AppTheme.primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const ChangePasswordDialog(),
                );
              },
              child: const Text(
                'Trocar Senha',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: _buildIconFrame(Icons.category_rounded, Colors.teal),
            title: const Text(
              'Categorias e Serviços Locais',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
            ),
            onTap: () {
              context.go('/settings/categories');
            },
          ),
          const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: Color(0xFFF1F5F9),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: _buildIconFrame(Icons.payments_rounded, Colors.orange),
            title: const Text(
              'Formas de Pagamento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
            ),
            onTap: () {
              context.go('/settings/payments');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardPreferencesCard(
    BuildContext context,
    SettingsLoaded state,
  ) {
    final prefs = state.dashboardPreferences;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildToggle(
            title: 'Agenda da Semana',
            subtitle: 'Exibir a lista dos próximos pacientes e atendimentos.',
            icon: Icons.calendar_view_week_rounded,
            color: Colors.indigo,
            value: prefs.showWeeklyAppointments,
            onChanged: (val) {
              final newPrefs = prefs.copyWith(showWeeklyAppointments: val);
              context.read<SettingsBloc>().add(
                UpdateDashboardPreferences(newPrefs),
              );
            },
          ),
          const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: Color(0xFFF1F5F9),
          ),
          _buildToggle(
            title: 'Faturamento Mensal',
            subtitle: 'Exibir faturamento bruto do mês atual.',
            icon: Icons.account_balance_wallet_rounded,
            color: Colors.green,
            value: prefs.showMonthlyIncome,
            onChanged: (val) {
              final newPrefs = prefs.copyWith(showMonthlyIncome: val);
              context.read<SettingsBloc>().add(
                UpdateDashboardPreferences(newPrefs),
              );
            },
          ),
          const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: Color(0xFFF1F5F9),
          ),
          _buildToggle(
            title: 'Pagamentos Pendentes',
            subtitle: 'Exibir quantidade de mensalidades e cobranças pendentes.',
            icon: Icons.receipt_long_rounded,
            color: Colors.red,
            value: prefs.showActivePayments,
            onChanged: (val) {
              final newPrefs = prefs.copyWith(showActivePayments: val);
              context.read<SettingsBloc>().add(
                UpdateDashboardPreferences(newPrefs),
              );
            },
          ),
          const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: Color(0xFFF1F5F9),
          ),
          _buildToggle(
            title: 'Próxima Consulta',
            subtitle: 'Destacar o próximo atendimento agendado.',
            icon: Icons.next_plan_rounded,
            color: Colors.blue,
            value: prefs.showNextAppointment,
            onChanged: (val) {
              final newPrefs = prefs.copyWith(showNextAppointment: val);
              context.read<SettingsBloc>().add(
                UpdateDashboardPreferences(newPrefs),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggle({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: _buildIconFrame(icon, color),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildIconFrame(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

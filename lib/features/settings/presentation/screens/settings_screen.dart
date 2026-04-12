import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/side_menu.dart';
import '../bloc/settings/settings_bloc.dart';
import '../bloc/settings/settings_event.dart';
import '../bloc/settings/settings_state.dart';
import 'package:physigest/core/widgets/app_error_view.dart';
import 'change_password_dialog.dart';
import 'package:physigest/core/utils/app_alerts.dart';
import 'package:physigest/core/widgets/loading_overlay.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ScrollController _locksScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(LoadSettings());
  }

  @override
  void dispose() {
    _locksScrollController.dispose();
    super.dispose();
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
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsError) {
            AppAlerts.error(context, state.message);
          } else if (state.successMessage != null && (ModalRoute.of(context)?.isCurrent ?? false)) {
            AppAlerts.success(context, state.successMessage!);
            context.read<SettingsBloc>().add(ClearSettingsMessage());
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading && (state is! SettingsLoaded)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingsError && (state is! SettingsLoaded)) {
            return AppErrorView(
              message: state.message,
              onRetry: () => context.read<SettingsBloc>().add(LoadSettings()),
            );
          }

          final isLoading = state is SettingsLoading;

          return LoadingOverlay(
            isLoading: isLoading,
            message: "Salvando...",
            child: (state is SettingsLoaded)
                ? _buildContent(context, state)
                : const SizedBox.shrink(),
          );
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
              _buildSectionTitle('Gerenciamento de Atendimento'),
              const SizedBox(height: 16),
              _buildWorkingDaysCard(context, state),
              const SizedBox(height: 32),
              _buildSectionTitle('Horários de Atendimento'),
              const SizedBox(height: 16),
              _buildWorkingHoursCard(context, state),
              const SizedBox(height: 32),
              _buildSectionTitle('Bloqueios na Agenda'),
              const SizedBox(height: 16),
              _buildAgendaLocksCard(context, state),
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

  Widget _buildWorkingDaysCard(BuildContext context, SettingsLoaded state) {
    final operatingDays = state.dashboardPreferences.operatingDays;
    final days = [
      {'label': 'Seg', 'value': 1},
      {'label': 'Ter', 'value': 2},
      {'label': 'Qua', 'value': 3},
      {'label': 'Qui', 'value': 4},
      {'label': 'Sex', 'value': 5},
      {'label': 'Sáb', 'value': 6},
      {'label': 'Dom', 'value': 0},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecione os dias em que haverá atividade na clínica:',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: days.map((day) {
              final isSelected = operatingDays.contains(day['value']);
              return FilterChip(
                label: Text(day['label'] as String),
                selected: isSelected,
                onSelected: (selected) {
                  final newList = List<int>.from(operatingDays);
                  if (selected) {
                    newList.add(day['value'] as int);
                  } else {
                    newList.remove(day['value'] as int);
                  }
                  newList.sort();
                  final newPrefs = state.dashboardPreferences.copyWith(operatingDays: newList);
                  context.read<SettingsBloc>().add(UpdateDashboardPreferences(newPrefs));
                },
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursCard(BuildContext context, SettingsLoaded state) {
    final prefs = state.dashboardPreferences;

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeRow(
            context,
            'Expediente',
            prefs.startTime,
            prefs.endTime,
            (start) => context.read<SettingsBloc>().add(
                  UpdateDashboardPreferences(
                      prefs.copyWith(startTime: start)),
                ),
            (end) => context.read<SettingsBloc>().add(
                  UpdateDashboardPreferences(
                      prefs.copyWith(endTime: end)),
                ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          _buildTimeRow(
            context,
            'Intervalo / Almoço',
            prefs.lunchStart,
            prefs.lunchEnd,
            (start) => context.read<SettingsBloc>().add(
                  UpdateDashboardPreferences(
                      prefs.copyWith(lunchStart: start)),
                ),
            (end) => context.read<SettingsBloc>().add(
                  UpdateDashboardPreferences(
                      prefs.copyWith(lunchEnd: end)),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(
    BuildContext context,
    String label,
    String start,
    String end,
    Function(String) onStartChanged,
    Function(String) onEndChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _timePickerButton(context, 'Início', start, onStartChanged),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('até', style: TextStyle(color: Colors.grey)),
            ),
            Expanded(
              child: _timePickerButton(context, 'Fim', end, onEndChanged),
            ),
          ],
        ),
      ],
    );
  }

  Widget _timePickerButton(
    BuildContext context,
    String label,
    String current,
    Function(String) onSelected,
  ) {
    return InkWell(
      onTap: () async {
        final parts = current.split(':');
        final time = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppTheme.primaryColor,
                  onPrimary: Colors.white,
                  onSurface: Color(0xFF1E293B),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          final formatted =
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          onSelected(formatted);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  current,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const Icon(Icons.access_time_rounded, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaLocksCard(BuildContext context, SettingsLoaded state) {
    if (state.agendaLocks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
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
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.event_available_rounded, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Nenhum bloqueio ativo na agenda.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

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
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: state.agendaLocks.length > 5 ? 350 : double.infinity,
        ),
        child: Scrollbar(
          controller: _locksScrollController,
          thumbVisibility: state.agendaLocks.length > 5,
          child: ListView.separated(
            controller: _locksScrollController,
            shrinkWrap: true,
            physics: state.agendaLocks.length > 5
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: state.agendaLocks.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 20, endIndent: 20),
            itemBuilder: (context, index) {
              final lock = state.agendaLocks[index];
              final isTotal = lock.type == 'total';

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: _buildIconFrame(
                  isTotal ? Icons.block_rounded : Icons.timer_outlined,
                  isTotal ? Colors.red : Colors.orange,
                ),
                title: Text(
                  _formatLockDate(lock),
                  style:
                      const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTotal
                          ? 'Dia Inteiro'
                          : '${lock.startTime} - ${lock.endTime}',
                      style: TextStyle(
                        color: isTotal
                            ? Colors.red.shade700
                            : Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    if (lock.description != null && lock.description!.isNotEmpty)
                      Text(
                        lock.description!,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.grey),
                  onPressed: () => _confirmDeleteLock(context, lock.id),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatLockDate(dynamic lock) {
    if (lock.date != null) {
      final d = lock.date as DateTime;
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    }
    if (lock.dates != null && (lock.dates as List).isNotEmpty) {
      final first = (lock.dates as List).first as DateTime;
      if ((lock.dates as List).length > 1) {
        return '${first.day.toString().padLeft(2, '0')}/${first.month.toString().padLeft(2, '0')} + ${(lock.dates as List).length - 1} dias';
      }
      return '${first.day.toString().padLeft(2, '0')}/${first.month.toString().padLeft(2, '0')}/${first.year}';
    }
    return 'Data não definida';
  }

  void _confirmDeleteLock(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover Bloqueio?'),
        content: const Text('Este horário voltará a ficar disponível para agendamentos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SettingsBloc>().add(DeleteAgendaLock(id));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remover'),
          ),
        ],
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
            color: Colors.black.withValues(alpha: 0.04),
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
          const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: Color(0xFFF1F5F9),
          ),
          _buildToggle(
            title: 'Pagamentos Pendentes',
            subtitle: 'Exibir pagamentos que ainda não foram quitados.',
            icon: Icons.history_rounded,
            color: Colors.amber,
            value: prefs.showPendingPayments,
            onChanged: (val) {
              final newPrefs = prefs.copyWith(showPendingPayments: val);
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
            title: 'Aniversariantes',
            subtitle: 'Exibir lista de pacientes que fazem aniversário no mês atual.',
            icon: Icons.cake_rounded,
            color: Colors.pink,
            value: prefs.showBirthdays,
            onChanged: (val) {
              final newPrefs = prefs.copyWith(showBirthdays: val);
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
            title: 'Pagamentos em Atraso',
            subtitle: 'Exibir cobranças com vencimento ultrapassado.',
            icon: Icons.warning_amber_rounded,
            color: Colors.deepOrange,
            value: prefs.showOverdueAppointments,
            onChanged: (val) {
              final newPrefs = prefs.copyWith(showOverdueAppointments: val);
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
            title: 'Gráfico de Ocupação',
            subtitle: 'Visualizar horários de maior movimento na clínica.',
            icon: Icons.bar_chart_rounded,
            color: Colors.teal,
            value: prefs.showOccupancyGraph,
            onChanged: (val) {
              final newPrefs = prefs.copyWith(showOccupancyGraph: val);
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

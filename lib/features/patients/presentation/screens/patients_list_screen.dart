import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/core/theme/app_theme.dart';
import 'package:physigest/core/widgets/side_menu.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_bloc.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_event.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_state.dart';
import 'package:physigest/features/patients/presentation/widgets/edit_patient_dialog.dart';
import 'package:physigest/core/widgets/app_error_view.dart';
import 'package:physigest/core/utils/app_alerts.dart';
import 'package:physigest/core/widgets/loading_overlay.dart';

class PatientsListScreen extends StatelessWidget {
  const PatientsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PatientBloc>()..add(LoadPatients()),
      child: BlocListener<PatientBloc, PatientState>(
        listenWhen: (previous, current) {
          // Só dispara alerta se for erro ou se for sucesso COM mensagem (add/update/delete)
          return current.status == PatientStatus.failure || 
                 (current.status == PatientStatus.success && current.successMessage != null);
        },
        listener: (context, state) {
          if (state.status == PatientStatus.failure && state.errorMessage != null) {
            Future.delayed(Duration.zero, () {
              if (context.mounted) AppAlerts.error(context, state.errorMessage!);
            });
          } else if (state.status == PatientStatus.success && state.successMessage != null) {
            Future.delayed(Duration.zero, () {
              if (context.mounted) AppAlerts.success(context, state.successMessage!);
            });
          }
        },
        child: const PatientsListView(),
      ),
    );
  }
}

class PatientsListView extends StatefulWidget {
  const PatientsListView({super.key});

  @override
  State<PatientsListView> createState() => _PatientsListViewState();
}

class _PatientsListViewState extends State<PatientsListView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Cinza leve mais moderno
      drawer: const SideMenu(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: const Text(
          'Pacientes',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPageHeader(context),
                const SizedBox(height: 32),
                _buildSearchField(context),
                const SizedBox(height: 32),
                _buildPatientsTable(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 600;

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pacientes",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                "Gerencie sua base de pacientes.",
                style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {
              final bloc = context.read<PatientBloc>();
              bloc.add(ClearPatientMessages());
              showDialog(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: bloc,
                  child: EditPatientDialog(),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
            label: const Text(
              "Novo Paciente",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pacientes",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const Text(
            "Gerencie sua base de pacientes.",
            style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final bloc = context.read<PatientBloc>();
                showDialog(
                  context: context,
                  builder: (_) => BlocProvider.value(
                    value: bloc,
                    child: const EditPatientDialog(),
                  ),
                );
              },
              icon: const Icon(
                Icons.add_rounded,
                size: 20,
                color: Colors.white,
              ),
              label: const Text(
                "Novo Paciente",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildSearchField(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;
    return Container(
      width: isDesktop ? 400 : double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: const InputDecoration(
          hintText: "Buscar paciente...",
          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPatientsTable(BuildContext context) {
    return BlocBuilder<PatientBloc, PatientState>(
      builder: (context, state) {
        if (state.status == PatientStatus.loading && state.patients.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(80),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == PatientStatus.failure && state.patients.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(80),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: AppErrorView(
              message: state.errorMessage ?? 'Erro ao carregar pacientes',
              onRetry: () => context.read<PatientBloc>().add(LoadPatients()),
            ),
          );
        }

        final filtered = state.patients
            .where(
              (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

        return LoadingOverlay(
          isLoading: state.status == PatientStatus.loading && state.patients.isNotEmpty,
          message: "Processando...",
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: filtered.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(80),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Nenhum paciente encontrado.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      _buildTableHeader(context),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        itemBuilder: (context, index) =>
                            _PatientRow(patient: filtered[index]),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          const Expanded(
            flex: 3,
            child: Text(
              "PACIENTE",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Expanded(
            flex: 3,
            child: Text(
              "STATUS",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
          const SizedBox(width: 48), // Espaço para o menu de ações
        ],
      ),
    );
  }
}

class _PatientRow extends StatelessWidget {
  final dynamic patient;
  const _PatientRow({required this.patient});

  @override
  Widget build(BuildContext context) {
    // Cores pastéis baseadas no nome para os avatares
    final List<Color> avatarColors = [
      const Color(0xFFCCFBF1),
      const Color(0xFFFEF3C7),
      const Color(0xFFF3E8FF),
      const Color(0xFFDBEAFE),
    ];
    final Color bgColor =
        avatarColors[patient.name.length % avatarColors.length];
    final Color textColor = Color.lerp(bgColor, Colors.black, 0.7)!;

    return InkWell(
      onTap: () => context.push('/patients/${patient.id}', extra: patient),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            // Avatar + Nome
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: bgColor,
                    child: Text(
                      patient.name[0].toUpperCase(),
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      patient.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                        fontSize: 15,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Status Badge
            Expanded(
              flex: 3,
              child: UnconstrainedBox(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: patient.status == 'active' 
                        ? Colors.teal.withValues(alpha: 0.1) 
                        : Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: patient.status == 'active' 
                        ? Colors.teal.withValues(alpha: 0.2) 
                        : Colors.grey.withValues(alpha: 0.2)
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: patient.status == 'active' ? Colors.teal : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        patient.displayStatus,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: patient.status == 'active' 
                              ? Colors.teal.shade700 
                              : Colors.grey.shade700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Menu de Ações
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'toggle_status') {
                  final isCurrentlyActive = patient.status == 'active';
                  final actionText = isCurrentlyActive ? 'Inativar' : 'Ativar';
                  final confirmationMessage = isCurrentlyActive
                      ? 'O paciente ficará inativo e não aparecerá nas buscas rápidas e dashboard.'
                      : 'O paciente voltará a ficar ativo em sua base de dados.';

                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text('$actionText Paciente?'),
                      content: Text(confirmationMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final newStatus =
                                isCurrentlyActive ? 'inactive' : 'active';
                            context.read<PatientBloc>().add(
                                  UpdatePatient(
                                      patient.copyWith(status: newStatus)),
                                );
                            Navigator.pop(dialogContext);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isCurrentlyActive ? Colors.red : Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(actionText),
                        ),
                      ],
                    ),
                  );
                }
              },
              icon: const Icon(
                Icons.more_horiz_rounded,
                color: Color(0xFF94A3B8),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle_status',
                  child: Row(
                    children: [
                      Icon(
                        patient.status == 'active' 
                            ? Icons.person_off_rounded 
                            : Icons.person_add_rounded,
                        size: 18,
                        color: const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        patient.status == 'active' ? "Inativar" : "Ativar",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

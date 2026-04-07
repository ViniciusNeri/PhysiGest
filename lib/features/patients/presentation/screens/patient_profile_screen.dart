// lib/features/patients/presentation/screens/patient_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/features/patients/domain/models/patient.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_bloc.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_event.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_state.dart';

// Import das novas Views
import '../views/patient_summary_view.dart';
import '../bloc/patient_activities_bloc.dart';
import '../views/patient_agenda_view.dart';
import '../views/patient_anamnesis_view.dart';
import '../views/patient_finance_view.dart';
import '../views/patient_gallery_view.dart';
import '../bloc/patient_financial_bloc.dart';
import '../bloc/patient_financial_event.dart';
import '../widgets/edit_patient_dialog.dart';
import 'package:physigest/core/widgets/loading_overlay.dart';
import 'package:physigest/core/utils/app_alerts.dart';

class PatientProfileScreen extends StatefulWidget {
  final Patient patient;
  const PatientProfileScreen({super.key, required this.patient});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PatientBloc _patientBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _patientBloc = getIt<PatientBloc>()..add(LoadPatients());
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Nota: Como o BlocProvider(create: ...) fecha o bloco automaticamente, 
    // não precisamos dar dispose manual aqui se passarmos o factory.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _patientBloc,
      child: BlocConsumer<PatientBloc, PatientState>(
        listenWhen: (previous, current) {
          // Só dispara alerta se for erro ou se for sucesso COM mensagem (add/update/delete)
          return current.status == PatientStatus.failure || 
                 (current.status == PatientStatus.success && current.successMessage != null);
        },
        listener: (context, state) {
          // Pequeno delay para garantir que diálogos (como o EditPatientDialog) 
          // fechem ANTES dos alertas de sucesso serem mostrados, evitando conflitos de Navigator.pop()
          if (state.status == PatientStatus.failure && state.errorMessage != null) {
            Future.delayed(Duration.zero, () {
              if (mounted) AppAlerts.error(context, state.errorMessage!);
            });
          } else if (state.status == PatientStatus.success && state.successMessage != null) {
            Future.delayed(Duration.zero, () {
              if (mounted) AppAlerts.success(context, state.successMessage!);
            });
          }
        },
        builder: (context, state) {
          // No profile, garantimos que temos o paciente mais atualizado do estado
          final p = state.patients.isEmpty 
            ? widget.patient 
            : state.patients.cast<Patient>().firstWhere(
                (p) => p.id == widget.patient.id,
                orElse: () => widget.patient,
              );
          final isDesktop = MediaQuery.of(context).size.width >= 600;

          return LoadingOverlay(
            isLoading: state.status == PatientStatus.loading,
            message: "Carregando...",
            child: Scaffold(
              backgroundColor: const Color(0xFFF1F5F9),
              appBar: _buildAppBar(p, isDesktop),
              body: TabBarView(
                controller: _tabController,
                children: [
                  BlocProvider(
                    create: (context) => getIt<PatientActivitiesBloc>()
                      ..add(LoadPatientActivities(p.id)),
                    child: PatientSummaryView(patient: p),
                  ),
                  PatientAgendaView(patient: p),
                  PatientAnamnesisView(patient: p),
                  BlocProvider(
                    create: (context) => getIt<PatientFinancialBloc>()
                      ..add(LoadFinancialSummary(p.id)),
                    child: PatientFinanceView(patient: p),
                  ),
                  const Center(child: Text("Anexos em breve")),
                  PatientGalleryView(patient: p),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Patient p, bool isDesktop) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p.name,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            const Text(
              "Prontuário Digital Ativo",
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ],
        ),
        actions: [
          if (isDesktop)
            Padding(
              padding: const EdgeInsets.only(
                right: 24.0,
                top: 12.0,
                bottom: 12.0,
              ),
              child: OutlinedButton.icon(
                onPressed: () {
                  final bloc = context.read<PatientBloc>();
                  bloc.add(ClearPatientMessages());
                  showDialog(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: bloc,
                      child: EditPatientDialog(patient: p),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text(
                  "Editar Perfil",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF64748B)),
                onPressed: () {
                  final bloc = context.read<PatientBloc>();
                  bloc.add(ClearPatientMessages());
                  showDialog(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: bloc,
                      child: EditPatientDialog(patient: p),
                    ),
                  );
                },
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFF7C3AED),
          labelColor: const Color(0xFF0D9488),
          unselectedLabelColor: const Color(0xFF94A3B8),
          tabs: const [
            Tab(text: 'RESUMO'),
            Tab(text: 'AGENDA'),
            Tab(text: 'ANAMNESE'),
            Tab(text: 'FINANCEIRO'),
            Tab(text: 'ANEXOS'),
            Tab(text: 'FOTOS'),
          ],
        ),
      ),
    );
  }
}

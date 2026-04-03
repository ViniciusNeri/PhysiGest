// lib/features/patients/presentation/screens/patient_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/features/patients/domain/models/patient.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_bloc.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_state.dart';

// Import das novas Views
import '../views/patient_summary_view.dart';
import '../views/patient_agenda_view.dart';
import '../views/patient_anamnesis_view.dart';
import '../views/patient_finance_view.dart';
import '../views/patient_gallery_view.dart';
import '../bloc/patient_financial_bloc.dart';
import '../bloc/patient_financial_event.dart';
import '../widgets/edit_patient_dialog.dart';

class PatientProfileScreen extends StatefulWidget {
  final Patient patient;
  const PatientProfileScreen({super.key, required this.patient});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<PatientBloc>(),
      child: BlocBuilder<PatientBloc, PatientState>(
        builder: (context, state) {
          final p = state.patients.firstWhere(
            (p) => p.id == widget.patient.id,
            orElse: () => widget.patient,
          );
          final isDesktop = MediaQuery.of(context).size.width >= 600;

          return Scaffold(
            backgroundColor: const Color(0xFFF1F5F9),
            appBar: _buildAppBar(p, isDesktop),
            body: TabBarView(
              controller: _tabController,
              children: [
                PatientSummaryView(patient: p),
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
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Patient p, bool isDesktop) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
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
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => EditPatientDialog(patient: p),
                ),
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
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => EditPatientDialog(patient: p),
                ),
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

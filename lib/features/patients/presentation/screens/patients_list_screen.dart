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

class PatientsListScreen extends StatelessWidget {
  const PatientsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PatientBloc>()..add(LoadPatients()),
      child: BlocListener<PatientBloc, PatientState>(
        listener: (context, state) {
          if (state.status == PatientStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
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
              showDialog(
                context: context,
                builder: (_) => BlocProvider.value(
                  value: bloc,
                  child: const EditPatientDialog(),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: BlocBuilder<PatientBloc, PatientState>(
        builder: (context, state) {
          if (state.status == PatientStatus.loading) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final filtered = state.patients
              .where(
                (p) =>
                    p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

          return Column(
            children: [
              // Cabeçalho da "Tabela"
              _buildTableHeader(context),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              // Lista de itens
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
          );
        },
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;
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
          if (isDesktop)
            const Expanded(
              flex: 2,
              child: Text(
                "NASCIMENTO",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          if (isDesktop)
            const Expanded(
              flex: 2,
              child: Text(
                "TELEFONE",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          Expanded(
            flex: isDesktop ? 1 : 2,
            child: const Text(
              "TRATAMENTOS",
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
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

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
                  Text(
                    patient.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            // Idade (Suposição de campo, ajuste conforme seu modelo)
            if (isDesktop)
              Expanded(
                flex: 2,
                child: Text(
                  patient.displayBirthDate,
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            // Telefone
            if (isDesktop)
              Expanded(
                flex: 2,
                child: Text(
                  patient.phone,
                  style: TextStyle(color: const Color(0xFF64748B)),
                ),
              ),
            // Badge de Tratamentos
            Expanded(
              flex: isDesktop ? 1 : 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${patient.completedAppointments} sessões",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
            // Menu de Ações
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.more_horiz_rounded,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

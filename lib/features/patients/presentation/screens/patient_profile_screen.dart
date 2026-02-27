import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/core/theme/app_theme.dart';
import 'package:physigest/features/patients/domain/models/patient.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_bloc.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_event.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_state.dart';

class PatientProfileScreen extends StatefulWidget {
  final Patient patient;

  const PatientProfileScreen({super.key, required this.patient});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  // Cores do Padrão PhysiGest
  static const Color azulPetroleo = Color(0xFF004D4D);
  static const Color roxoClaro = Color(0xFF9370DB);

  @override
  void initState() {
    super.initState();
    // Expandido para 6 abas conforme solicitado
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<PatientBloc>(),
      child: BlocBuilder<PatientBloc, PatientState>(
        builder: (context, state) {
          final currentPatient = state.patients.firstWhere(
            (p) => p.id == widget.patient.id,
            orElse: () => widget.patient,
          );

          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FE),
            appBar: AppBar(
              title: Text(
                currentPatient.name,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black87),
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true, // Necessário para 6 abas
                labelColor: azulPetroleo,
                unselectedLabelColor: Colors.grey,
                indicatorColor: roxoClaro,
                tabs: const [
                  Tab(text: 'Dados'),
                  Tab(text: 'Agendamentos'),
                  Tab(text: 'Anamnese'),
                  Tab(text: 'Financeiro'),
                  Tab(text: 'Anexos'),
                  Tab(text: 'Fotos'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildDataTab(currentPatient),
                _buildPlaceholderTab(Icons.calendar_month, 'Próximas Sessões'),
                _buildAnamnesisTab(context, currentPatient),
                _buildPlaceholderTab(Icons.payments, 'Histórico de Pagamentos'),
                _buildPlaceholderTab(Icons.description, 'Documentos em PDF'),
                _buildGalleryTab(context, currentPatient),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- ABA 1: DADOS ---
  Widget _buildDataTab(Patient patient) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: azulPetroleo.withOpacity(0.1),
                child: Text(
                  patient.name[0].toUpperCase(),
                  style: const TextStyle(fontSize: 40, color: azulPetroleo, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),
              _buildInfoCard('E-mail', patient.email, Icons.email_outlined),
              const SizedBox(height: 16),
              _buildInfoCard('Telefone', patient.phone, Icons.phone_outlined),
              const SizedBox(height: 16),
              _buildInfoCard('Nascimento', patient.birthDate, Icons.calendar_today_outlined),
              const SizedBox(height: 16),
              _buildInfoCard('Profissão', patient.occupation, Icons.work_outline),
            ],
          ),
        ),
      ),
    );
  }

  // --- ABA 3: ANAMNESE ---
  Widget _buildAnamnesisTab(BuildContext context, Patient patient) {
    final anamnesis = patient.anamnesis;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildEditableCard('Queixa Principal', anamnesis.mainComplaint, (val) {
            final newAnamnesis = anamnesis.copyWith(mainComplaint: val);
            context.read<PatientBloc>().add(UpdatePatient(patient.copyWith(anamnesis: newAnamnesis)));
          }),
          const SizedBox(height: 16),
          _buildEditableCard('Histórico Clínico', anamnesis.historic, (val) {
            final newAnamnesis = anamnesis.copyWith(historic: val);
            context.read<PatientBloc>().add(UpdatePatient(patient.copyWith(anamnesis: newAnamnesis)));
          }),
        ],
      ),
    );
  }

  // --- ABA 6: FOTOS ---
  Widget _buildGalleryTab(BuildContext context, Patient patient) {
    return Column(
      children: [
        Expanded(
          child: patient.photoPaths.isEmpty
              ? _buildPlaceholderTab(Icons.photo_library, 'Nenhuma foto na galeria')
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: patient.photoPaths.length,
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(patient.photoPaths[index]), fit: BoxFit.cover),
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () async {
              final XFile? image = await _picker.pickImage(source: ImageSource.camera);
              if (image != null && context.mounted) {
                context.read<PatientBloc>().add(AddPhotoToPatient(patient.id, image.path));
              }
            },
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            label: const Text('Tirar Foto', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: roxoClaro,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGETS DE SUPORTE ---

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, color: azulPetroleo),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableCard(String title, String value, Function(String) onSave) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: azulPetroleo)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value,
            maxLines: 3,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8F9FE),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            onChanged: onSave,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(IconData icon, String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(text, style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
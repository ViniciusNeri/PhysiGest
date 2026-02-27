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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          // Find the latest version of this patient from state update
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
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppTheme.primaryColor,
                tabs: const [
                  Tab(text: 'Dados'),
                  Tab(text: 'Anamnese'),
                  Tab(text: 'Galeria'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildDataTab(currentPatient),
                _buildAnamnesisTab(context, currentPatient),
                _buildGalleryTab(context, currentPatient),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataTab(Patient patient) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    patient.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 40, color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                  ),
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

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnamnesisTab(BuildContext context, Patient patient) {
    Anamnesis currentAnamnesis = patient.anamnesis;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAnamnesisCard(
                title: 'Queixa Principal',
                initialValue: currentAnamnesis.mainComplaint,
                onSave: (val) {
                  final newAnamnesis = currentAnamnesis.copyWith(mainComplaint: val);
                  context.read<PatientBloc>().add(UpdatePatient(patient.copyWith(anamnesis: newAnamnesis)));
                },
              ),
              const SizedBox(height: 16),
              _buildAnamnesisCard(
                title: 'Histórico',
                initialValue: currentAnamnesis.historic,
                onSave: (val) {
                  final newAnamnesis = currentAnamnesis.copyWith(historic: val);
                  context.read<PatientBloc>().add(UpdatePatient(patient.copyWith(anamnesis: newAnamnesis)));
                },
              ),
              const SizedBox(height: 16),
              _buildAnamnesisCard(
                title: 'Diagnóstico Clínico',
                initialValue: currentAnamnesis.clinicalDiagnosis,
                onSave: (val) {
                  final newAnamnesis = currentAnamnesis.copyWith(clinicalDiagnosis: val);
                  context.read<PatientBloc>().add(UpdatePatient(patient.copyWith(anamnesis: newAnamnesis)));
                },
              ),
              const SizedBox(height: 16),
              _buildAnamnesisCard(
                title: 'Medicações',
                initialValue: currentAnamnesis.medications,
                onSave: (val) {
                  final newAnamnesis = currentAnamnesis.copyWith(medications: val);
                  context.read<PatientBloc>().add(UpdatePatient(patient.copyWith(anamnesis: newAnamnesis)));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnamnesisCard({required String title, required String initialValue, required Function(String) onSave}) {
    final controller = TextEditingController(text: initialValue);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor)),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Descreva $title...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: const Color(0xFFF8F9FE),
            ),
            onSubmitted: onSave,
            onEditingComplete: () => onSave(controller.text),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryTab(BuildContext context, Patient patient) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: patient.photoPaths.isEmpty
                ? const Center(
                    child: Text('Nenhuma foto adicionada.', style: TextStyle(color: Colors.grey, fontSize: 16)))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: patient.photoPaths.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(patient.photoPaths[index]),
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                if (image != null && context.mounted) {
                  context.read<PatientBloc>().add(AddPhotoToPatient(patient.id, image.path));
                }
              },
              icon: const Icon(Icons.add_a_photo, color: Colors.white),
              label: const Text('Adicionar Foto',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          )
        ],
      ),
    );
  }
}

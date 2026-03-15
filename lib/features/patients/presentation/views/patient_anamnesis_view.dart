// lib/features/patients/presentation/views/patient_anamnesis_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/patient.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';

class PatientAnamnesisView extends StatelessWidget {
  final Patient patient;
  const PatientAnamnesisView({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) _buildNavSidebar(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(isDesktop ? 48.0 : 24.0),
                children: [
                  Text("Avaliação Clínica", style: TextStyle(fontSize: isDesktop ? 28 : 24, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B))),
                  const SizedBox(height: 24),
                  _buildVitalsRow(isDesktop),
                  const SizedBox(height: 32),
                  
                  // Seções de Anamnese Profissional
                  _buildSectionTitle("História Médica"),
                  _buildEditor(context, "Queixa Principal (QP)", patient.anamnesis.mainComplaint, (v) => _update(context, patient.anamnesis.copyWith(mainComplaint: v))),
                  _buildEditor(context, "História da Moléstia Atual (HMA)", patient.anamnesis.currentIllness, (v) => _update(context, patient.anamnesis.copyWith(currentIllness: v))),
                  _buildEditor(context, "História Médica Pregressa (HMP)", patient.anamnesis.historic, (v) => _update(context, patient.anamnesis.copyWith(historic: v))),
                  _buildEditor(context, "Histórico Familiar", patient.anamnesis.familyHistory, (v) => _update(context, patient.anamnesis.copyWith(familyHistory: v))),
                  
                  _buildSectionTitle("Estilo de Vida e Medicamentos"),
                  _buildEditor(context, "Hábitos de Vida", patient.anamnesis.lifestyleHabits, (v) => _update(context, patient.anamnesis.copyWith(lifestyleHabits: v))),
                  _buildEditor(context, "Medicamentos em Uso", patient.anamnesis.medications, (v) => _update(context, patient.anamnesis.copyWith(medications: v))),
                  
                  _buildSectionTitle("Exame e Diagnóstico"),
                  _buildEditor(context, "Exame Físico", patient.anamnesis.physicalExam, (v) => _update(context, patient.anamnesis.copyWith(physicalExam: v))),
                  _buildEditor(context, "Diagnóstico Clínico", patient.anamnesis.clinicalDiagnosis, (v) => _update(context, patient.anamnesis.copyWith(clinicalDiagnosis: v))),
                  _buildEditor(context, "Plano de Tratamento", patient.anamnesis.treatmentPlan, (v) => _update(context, patient.anamnesis.copyWith(treatmentPlan: v))),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavSidebar() {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: const [
          ListTile(
            leading: Icon(Icons.history_edu, color: Color(0xFF0D9488)),
            title: Text("História Médica", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ),
          ListTile(
            leading: Icon(Icons.monitor_heart, color: Color(0xFF94A3B8)),
            title: Text("Estilo de Vida", style: TextStyle(color: Color(0xFF64748B))),
          ),
          ListTile(
            leading: Icon(Icons.accessibility_new, color: Color(0xFF94A3B8)),
            title: Text("Exame e Diagnóstico", style: TextStyle(color: Color(0xFF64748B))),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
          const Divider(color: Color(0xFFE2E8F0)),
        ],
      ),
    );
  }

  Widget _buildVitalsRow(bool isDesktop) {
    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: _vitalBox("Peso", "74kg", Icons.scale)),
          const SizedBox(width: 16),
          Expanded(child: _vitalBox("Altura", "1.78m", Icons.height)),
          const SizedBox(width: 16),
          Expanded(child: _vitalBox("IMC", "23.4", Icons.monitor_weight)),
        ],
      );
    } else {
      return Column(
        children: [
          _vitalBox("Peso", "74kg", Icons.scale),
          const SizedBox(height: 12),
          _vitalBox("Altura", "1.78m", Icons.height),
          const SizedBox(height: 12),
          _vitalBox("IMC", "23.4", Icons.monitor_weight),
        ],
      );
    }
  }

  Widget _vitalBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF0FDFA), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF0D9488), size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.bold)), 
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1E293B)))
            ]
          ),
        ],
      ),
    );
  }

  Widget _buildEditor(BuildContext context, String title, String value, Function(String) onSave) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155), fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value, 
            maxLines: 4, 
            onChanged: onSave, 
            decoration: InputDecoration(
              filled: true, 
              fillColor: Colors.white, 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2)),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ]
      ),
    );
  }

  void _update(BuildContext context, Anamnesis anamnesis) {
    context.read<PatientBloc>().add(UpdatePatient(patient.copyWith(anamnesis: anamnesis)));
  }
}
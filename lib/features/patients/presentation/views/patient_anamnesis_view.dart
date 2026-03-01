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
    return Row(
      children: [
        _buildNavSidebar(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(48),
            children: [
              const Text("Avaliação Clínica", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 32),
              _buildVitalsRow(),
              const SizedBox(height: 40),
              _buildEditor(
                context,
                "Queixa Principal",
                patient.anamnesis.mainComplaint,
                (val) => _update(context, patient.anamnesis.copyWith(mainComplaint: val)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavSidebar() {
    return Container(
      width: 200,
      decoration: const BoxDecoration(border: Border(right: BorderSide(color: Color(0xFFE2E8F0)))),
      child: ListView(
        children: const [
          ListTile(title: Text("Queixa Principal", style: TextStyle(fontWeight: FontWeight.bold))),
          ListTile(title: Text("Sinais Vitais")),
          ListTile(title: Text("Exame Físico")),
        ],
      ),
    );
  }

  Widget _buildVitalsRow() {
    return Row(
      children: [
        _vitalBox("Peso", "74kg"),
        const SizedBox(width: 16),
        _vitalBox("Altura", "1.78m"),
        const SizedBox(width: 16),
        _vitalBox("IMC", "23.4"),
      ],
    );
  }

  Widget _vitalBox(String label, String value) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 12)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
    ),
  );

  Widget _buildEditor(BuildContext context, String title, String value, Function(String) onSave) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      TextFormField(initialValue: value, maxLines: 5, onChanged: onSave, decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
    ]);
  }

  void _update(BuildContext context, dynamic anamnesis) {
    context.read<PatientBloc>().add(UpdatePatient(patient.copyWith(anamnesis: anamnesis)));
  }
}
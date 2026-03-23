import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/patient.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';

class PatientAnamnesisView extends StatefulWidget {
  final Patient patient;
  const PatientAnamnesisView({super.key, required this.patient});

  @override
  State<PatientAnamnesisView> createState() => _PatientAnamnesisViewState();
}

class _PatientAnamnesisViewState extends State<PatientAnamnesisView> {
  late TextEditingController _mainComplaintCtrl;
  late TextEditingController _currentIllnessCtrl;
  late TextEditingController _historicCtrl;
  late TextEditingController _familyHistoryCtrl;
  late TextEditingController _lifestyleHabitsCtrl;
  late TextEditingController _medicationsCtrl;
  late TextEditingController _physicalExamCtrl;
  late TextEditingController _clinicalDiagnosisCtrl;
  late TextEditingController _treatmentPlanCtrl;

  @override
  void initState() {
    super.initState();
    final anamnesis = widget.patient.anamnesis;
    _mainComplaintCtrl = TextEditingController(text: anamnesis.mainComplaint);
    _currentIllnessCtrl = TextEditingController(text: anamnesis.currentIllness);
    _historicCtrl = TextEditingController(text: anamnesis.historic);
    _familyHistoryCtrl = TextEditingController(text: anamnesis.familyHistory);
    _lifestyleHabitsCtrl = TextEditingController(
      text: anamnesis.lifestyleHabits,
    );
    _medicationsCtrl = TextEditingController(text: anamnesis.medications);
    _physicalExamCtrl = TextEditingController(text: anamnesis.physicalExam);
    _clinicalDiagnosisCtrl = TextEditingController(
      text: anamnesis.clinicalDiagnosis,
    );
    _treatmentPlanCtrl = TextEditingController(text: anamnesis.treatmentPlan);
  }

  @override
  void didUpdateWidget(covariant PatientAnamnesisView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Evita recriar ou sobrescrever os controllers enquanto o usuário digita
    // a menos que o paciente seja um paciente completamente diferente
    if (oldWidget.patient.id != widget.patient.id) {
      final anamnesis = widget.patient.anamnesis;
      _mainComplaintCtrl.text = anamnesis.mainComplaint;
      _currentIllnessCtrl.text = anamnesis.currentIllness;
      _historicCtrl.text = anamnesis.historic;
      _familyHistoryCtrl.text = anamnesis.familyHistory;
      _lifestyleHabitsCtrl.text = anamnesis.lifestyleHabits;
      _medicationsCtrl.text = anamnesis.medications;
      _physicalExamCtrl.text = anamnesis.physicalExam;
      _clinicalDiagnosisCtrl.text = anamnesis.clinicalDiagnosis;
      _treatmentPlanCtrl.text = anamnesis.treatmentPlan;
    }
  }

  @override
  void dispose() {
    _mainComplaintCtrl.dispose();
    _currentIllnessCtrl.dispose();
    _historicCtrl.dispose();
    _familyHistoryCtrl.dispose();
    _lifestyleHabitsCtrl.dispose();
    _medicationsCtrl.dispose();
    _physicalExamCtrl.dispose();
    _clinicalDiagnosisCtrl.dispose();
    _treatmentPlanCtrl.dispose();
    super.dispose();
  }

  void _saveAnamnesis() {
    final updatedAnamnesis = Anamnesis(
      mainComplaint: _mainComplaintCtrl.text,
      currentIllness: _currentIllnessCtrl.text,
      historic: _historicCtrl.text,
      familyHistory: _familyHistoryCtrl.text,
      lifestyleHabits: _lifestyleHabitsCtrl.text,
      medications: _medicationsCtrl.text,
      physicalExam: _physicalExamCtrl.text,
      clinicalDiagnosis: _clinicalDiagnosisCtrl.text,
      treatmentPlan: _treatmentPlanCtrl.text,
    );

    context.read<PatientBloc>().add(
      UpdatePatient(widget.patient.copyWith(anamnesis: updatedAnamnesis)),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("A Anamnese foi salva com sucesso no Prontuário."),
        backgroundColor: Colors.green,
      ),
    );
  }

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
                  Text(
                    "Avaliação Clínica",
                    style: TextStyle(
                      fontSize: isDesktop ? 28 : 24,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildVitalsRow(isDesktop),
                  const SizedBox(height: 32),

                  // Seções de Anamnese Profissional
                  _buildSectionTitle("História Médica"),
                  _buildEditor("Queixa Principal (QP)", _mainComplaintCtrl),
                  _buildEditor(
                    "História da Moléstia Atual (HMA)",
                    _currentIllnessCtrl,
                  ),
                  _buildEditor(
                    "História Médica Pregressa (HMP)",
                    _historicCtrl,
                  ),
                  _buildEditor("Histórico Familiar", _familyHistoryCtrl),

                  _buildSectionTitle("Estilo de Vida e Medicamentos"),
                  _buildEditor("Hábitos de Vida", _lifestyleHabitsCtrl),
                  _buildEditor("Medicamentos em Uso", _medicationsCtrl),

                  _buildSectionTitle("Exame e Diagnóstico"),
                  _buildEditor("Exame Físico", _physicalExamCtrl),
                  _buildEditor("Diagnóstico Clínico", _clinicalDiagnosisCtrl),
                  _buildEditor("Plano de Tratamento", _treatmentPlanCtrl),

                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveAnamnesis,
                      icon: const Icon(Icons.save_rounded, color: Colors.white),
                      label: const Text(
                        "SALVAR ALTERAÇÕES DA ANAMNESE",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),
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
            title: Text(
              "História Médica",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.monitor_heart, color: Color(0xFF94A3B8)),
            title: Text(
              "Estilo de Vida",
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ListTile(
            leading: Icon(Icons.accessibility_new, color: Color(0xFF94A3B8)),
            title: Text(
              "Exame e Diagnóstico",
              style: TextStyle(color: Color(0xFF64748B)),
            ),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D9488),
            ),
          ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0D9488), size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditor(String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF0D9488),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}

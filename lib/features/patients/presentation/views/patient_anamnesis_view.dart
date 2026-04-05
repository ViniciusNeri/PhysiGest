import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../domain/models/patient.dart';
import '../bloc/anamnesis_bloc.dart';
import '../bloc/anamnesis_event.dart';
import '../bloc/anamnesis_state.dart';
import 'package:physigest/core/widgets/app_error_view.dart';

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

  // Vitals controllers
  late TextEditingController _weightCtrl;
  late TextEditingController _heightCtrl;

  // Scroll anchors
  final ScrollController _scrollCtrl = ScrollController();
  final _keyHistory = GlobalKey();
  final _keyLifestyle = GlobalKey();
  final _keyExam = GlobalKey();

  int _activeSectionIndex = 0;

  @override
  void initState() {
    super.initState();
    _mainComplaintCtrl = TextEditingController();
    _currentIllnessCtrl = TextEditingController();
    _historicCtrl = TextEditingController();
    _familyHistoryCtrl = TextEditingController();
    _lifestyleHabitsCtrl = TextEditingController();
    _medicationsCtrl = TextEditingController();
    _physicalExamCtrl = TextEditingController();
    _clinicalDiagnosisCtrl = TextEditingController();
    _treatmentPlanCtrl = TextEditingController();
    _weightCtrl = TextEditingController();
    _heightCtrl = TextEditingController();
  }

  void _updateControllers(Anamnesis anamnesis) {
    _mainComplaintCtrl.text = anamnesis.mainComplaint;
    _currentIllnessCtrl.text = anamnesis.currentIllness;
    _historicCtrl.text = anamnesis.historic;
    _familyHistoryCtrl.text = anamnesis.familyHistory;
    _lifestyleHabitsCtrl.text = anamnesis.lifestyleHabits;
    _medicationsCtrl.text = anamnesis.medications;
    _physicalExamCtrl.text = anamnesis.physicalExam;
    _clinicalDiagnosisCtrl.text = anamnesis.clinicalDiagnosis;
    _treatmentPlanCtrl.text = anamnesis.treatmentPlan;
    _weightCtrl.text = anamnesis.weight;
    _heightCtrl.text = anamnesis.height;
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
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToKey(GlobalKey key, int sectionIndex) {
    setState(() => _activeSectionIndex = sectionIndex);
    final ctx = key.currentContext;
    if (ctx == null || !_scrollCtrl.hasClients) return;
    final renderObject = ctx.findRenderObject();
    if (renderObject == null) return;
    final viewport = RenderAbstractViewport.of(renderObject);
    final revealedOffset = viewport.getOffsetToReveal(renderObject, 0.0);
    _scrollCtrl.animateTo(
      revealedOffset.offset.clamp(0.0, _scrollCtrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  String _calcImc() {
    try {
      final w = double.parse(_weightCtrl.text.replaceAll(RegExp(r'[^0-9.]'), ''));
      final h = double.parse(_heightCtrl.text.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (h <= 0) return '-';
      final hInM = h > 3 ? h / 100 : h;
      final imc = w / (hInM * hInM);
      return imc.toStringAsFixed(1);
    } catch (_) {
      return '-';
    }
  }

  void _saveAnamnesis(BuildContext context) {
    final anamnesis = Anamnesis(
      mainComplaint: _mainComplaintCtrl.text,
      currentIllness: _currentIllnessCtrl.text,
      historic: _historicCtrl.text,
      familyHistory: _familyHistoryCtrl.text,
      lifestyleHabits: _lifestyleHabitsCtrl.text,
      medications: _medicationsCtrl.text,
      physicalExam: _physicalExamCtrl.text,
      clinicalDiagnosis: _clinicalDiagnosisCtrl.text,
      treatmentPlan: _treatmentPlanCtrl.text,
      weight: _weightCtrl.text,
      height: _heightCtrl.text,
    );

    context.read<AnamnesisBloc>().add(
      SaveAnamnesis(patientId: widget.patient.id, anamnesis: anamnesis),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AnamnesisBloc>()..add(LoadAnamnesis(widget.patient.id)),
      child: BlocConsumer<AnamnesisBloc, AnamnesisState>(
        listener: (context, state) {
          if (state.status == AnamnesisStatus.success && state.anamnesis != null) {
            _updateControllers(state.anamnesis!);
          }
          if (state.status == AnamnesisStatus.saveSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("A Anamnese foi salva com sucesso!"),
                backgroundColor: Colors.green.shade800,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
          if (state.status == AnamnesisStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade800,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == AnamnesisStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)));
          }

          if (state.status == AnamnesisStatus.failure && state.anamnesis == null) {
            return AppErrorView(
              message: state.errorMessage ?? "Erro ao carregar anamnese",
              onRetry: () => context.read<AnamnesisBloc>().add(LoadAnamnesis(widget.patient.id)),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 800;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop) _buildNavSidebar(),
                  Expanded(
                    child: ListView(
                      controller: _scrollCtrl,
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

                        // História Médica
                        _buildSectionTitle("História Médica", key: _keyHistory),
                        _buildEditor("Queixa Principal (QP)", _mainComplaintCtrl),
                        _buildEditor("História da Moléstia Atual (HMA)", _currentIllnessCtrl),
                        _buildEditor("História Médica Pregressa (HMP)", _historicCtrl),
                        _buildEditor("Histórico Familiar", _familyHistoryCtrl),

                        _buildSectionTitle("Estilo de Vida e Medicamentos", key: _keyLifestyle),
                        _buildEditor("Hábitos de Vida", _lifestyleHabitsCtrl),
                        _buildEditor("Medicamentos em Uso", _medicationsCtrl),

                        _buildSectionTitle("Exame e Diagnóstico", key: _keyExam),
                        _buildEditor("Exame Físico", _physicalExamCtrl),
                        _buildEditor("Diagnóstico Clínico", _clinicalDiagnosisCtrl),
                        _buildEditor("Plano de Tratamento", _treatmentPlanCtrl),

                        const SizedBox(height: 48),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: state.status == AnamnesisStatus.saving 
                                ? null 
                                : () => _saveAnamnesis(context),
                            icon: state.status == AnamnesisStatus.saving
                                ? const SizedBox(
                                    width: 20, 
                                    height: 20, 
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                  )
                                : const Icon(Icons.save_rounded, color: Colors.white),
                            label: Text(
                              state.status == AnamnesisStatus.saving ? "SALVANDO..." : "SALVAR ALTERAÇÕES DA ANAMNESE",
                              style: const TextStyle(
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
        },
      ),
    );
  }

  Widget _buildNavSidebar() {
    final sections = [
      (Icons.history_edu, "História Médica", _keyHistory),
      (Icons.monitor_heart, "Estilo de Vida", _keyLifestyle),
      (Icons.accessibility_new, "Exame e Diagnóstico", _keyExam),
    ];

    return Container(
      width: 230,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          for (int i = 0; i < sections.length; i++)
            _buildNavItem(
              icon: sections[i].$1,
              label: sections[i].$2,
              isActive: _activeSectionIndex == i,
              onTap: () => _scrollToKey(sections[i].$3, i),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF0FDFA) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isActive ? const Color(0xFF0D9488) : const Color(0xFF94A3B8),
                size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Key? key}) {
    return Padding(
      key: key,
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
          Expanded(child: _vitalEditable("Peso (kg)", _weightCtrl, Icons.scale)),
          const SizedBox(width: 16),
          Expanded(child: _vitalEditable("Altura (m ou cm)", _heightCtrl, Icons.height)),
          const SizedBox(width: 16),
          Expanded(child: _imcBox()),
        ],
      );
    } else {
      return Column(
        children: [
          _vitalEditable("Peso (kg)", _weightCtrl, Icons.scale),
          const SizedBox(height: 12),
          _vitalEditable("Altura (m ou cm)", _heightCtrl, Icons.height),
          const SizedBox(height: 12),
          _imcBox(),
        ],
      );
    }
  }

  Widget _vitalEditable(String label, TextEditingController ctrl, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0D9488), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: ctrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: Color(0xFF1E293B),
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: '—',
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imcBox() {
    final imc = _calcImc();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.monitor_weight, color: Color(0xFF0D9488), size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "IMC",
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                imc,
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

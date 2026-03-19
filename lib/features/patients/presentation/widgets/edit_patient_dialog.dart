import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/features/patients/domain/models/patient.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_bloc.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_event.dart';

class EditPatientDialog extends StatefulWidget {
  final Patient? patient;

  const EditPatientDialog({super.key, this.patient});

  @override
  State<EditPatientDialog> createState() => _EditPatientDialogState();
}

class _EditPatientDialogState extends State<EditPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _birthDateCtrl;
  late TextEditingController _occupationCtrl;

  // Cores do Padrão PhysiGest
  static const Color azulPetroleo = Color(0xFF004D4D);

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.patient?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.patient?.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.patient?.phone ?? '');
    _birthDateCtrl = TextEditingController(text: widget.patient?.birthDate ?? '');
    _occupationCtrl = TextEditingController(text: widget.patient?.occupation ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _birthDateCtrl.dispose();
    _occupationCtrl.dispose();
    super.dispose();
  }

  void _savePatient() {
    if (_formKey.currentState!.validate()) {
      final newPatient = Patient(
        id: widget.patient?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        phone: _phoneCtrl.text,
        birthDate: _birthDateCtrl.text,
        occupation: _occupationCtrl.text,
        anamnesis: widget.patient?.anamnesis ?? const Anamnesis(),
        photoPaths: widget.patient?.photoPaths ?? const [],
        financialHistory: widget.patient?.financialHistory ?? const [],
      );

      final bloc = getIt<PatientBloc>();
      if (widget.patient == null) {
        bloc.add(AddPatient(newPatient));
      } else {
        bloc.add(UpdatePatient(newPatient));
      }
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.patient != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFFF8F9FE),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Editar Cadastro' : 'Novo Paciente',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _buildTextFieldCard(
                    label: 'Nome Completo',
                    controller: _nameCtrl,
                    icon: Icons.person_outline,
                    validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFieldCard(
                    label: 'E-mail',
                    controller: _emailCtrl,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  
                  // Responsivo: Lado a Lado ou Um Embaixo do outro
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 400;
                      if (isWide) {
                        return Row(
                          children: [
                            Expanded(
                              child: _buildTextFieldCard(
                                label: 'Telefone',
                                controller: _phoneCtrl,
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextFieldCard(
                                label: 'Data de Nascimento',
                                controller: _birthDateCtrl,
                                icon: Icons.calendar_today_outlined,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildTextFieldCard(
                              label: 'Telefone',
                              controller: _phoneCtrl,
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            _buildTextFieldCard(
                              label: 'Data de Nascimento',
                              controller: _birthDateCtrl,
                              icon: Icons.calendar_today_outlined,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextFieldCard(
                    label: 'Profissão',
                    controller: _occupationCtrl,
                    icon: Icons.work_outline,
                  ),
                  const SizedBox(height: 32),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => context.pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          foregroundColor: const Color(0xFF64748B),
                        ),
                        child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _savePatient,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: azulPetroleo,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                        label: Text(
                          isEditing ? 'Salvar Alterações' : 'Cadastrar Paciente', 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldCard({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
          prefixIcon: Icon(icon, color: const Color(0xFF0D9488)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

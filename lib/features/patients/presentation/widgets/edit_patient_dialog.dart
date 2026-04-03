import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physigest/features/patients/domain/models/patient.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_bloc.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_event.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_state.dart';

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
  late TextEditingController _professionCtrl;

  String _selectedGender = 'male';

  // Cores do Padrão PhysiGest
  static const Color azulPetroleo = Color(0xFF004D4D);

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.patient?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.patient?.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.patient?.phone ?? '');
    _birthDateCtrl = TextEditingController(
      text: widget.patient?.displayBirthDate ?? '',
    );
    _professionCtrl = TextEditingController(
      text: widget.patient?.profession ?? '',
    );
    _selectedGender = widget.patient?.gender.toLowerCase() ?? 'male';
    if (!['male', 'female', 'other', 'masculino', 'feminino', 'outros'].contains(_selectedGender)) {
      _selectedGender = 'other';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _birthDateCtrl.dispose();
    _professionCtrl.dispose();
    super.dispose();
  }

  String _formatDateForApi(String date) {
    if (date.length != 10) return date;
    final parts = date.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0]}T00:00:00.000Z';
    }
    return date;
  }

  void _savePatient() {
    if (_formKey.currentState!.validate()) {
      final newPatient = Patient(
        id:
            widget.patient?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        phone: _phoneCtrl.text,
        birthDate: _formatDateForApi(_birthDateCtrl.text),
        gender: _selectedGender,
        profession: _professionCtrl.text,
        anamnesis: widget.patient?.anamnesis ?? const Anamnesis(),
        photoPaths: widget.patient?.photoPaths ?? const [],
        financialHistory: widget.patient?.financialHistory ?? const [],
      );

      final bloc = context.read<PatientBloc>();
      if (widget.patient == null) {
        bloc.add(AddPatient(newPatient));
      } else {
        bloc.add(UpdatePatient(newPatient));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.patient != null;
    final bool isDesktop = MediaQuery.of(context).size.width > 600;

    return BlocListener<PatientBloc, PatientState>(
      listenWhen: (previous, current) => previous.status == PatientStatus.loading && current.status != PatientStatus.loading,
      listener: (context, state) {
        if (state.status == PatientStatus.success) {
          context.pop();
        } else if (state.status == PatientStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFF8F9FE),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32.0 : 20.0),
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
                      Expanded(
                        child: Text(
                          isEditing ? 'Editar Cadastro' : 'Novo Paciente',
                          style: TextStyle(
                            fontSize: isDesktop ? 24 : 20,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF94A3B8),
                        ),
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildTextFieldCard(
                    label: 'Nome Completo',
                    controller: _nameCtrl,
                    icon: Icons.person_outline,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Campo obrigatório' : null,
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
                                inputFormatters: [PhoneInputFormatter()],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextFieldCard(
                                label: 'Data de Nascimento',
                                controller: _birthDateCtrl,
                                icon: Icons.calendar_today_outlined,
                                keyboardType: TextInputType.number,
                                inputFormatters: [DateInputFormatter()],
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
                              inputFormatters: [PhoneInputFormatter()],
                            ),
                            const SizedBox(height: 16),
                            _buildTextFieldCard(
                              label: 'Data de Nascimento',
                              controller: _birthDateCtrl,
                              icon: Icons.calendar_today_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [DateInputFormatter()],
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownCard(
                          label: 'Gênero',
                          value: _selectedGender,
                          items: ['male', 'female', 'other'],
                          icon: Icons.wc_outlined,
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedGender = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextFieldCard(
                          label: 'Profissão',
                          controller: _professionCtrl,
                          icon: Icons.work_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  if (isDesktop)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => context.pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            foregroundColor: const Color(0xFF64748B),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        BlocBuilder<PatientBloc, PatientState>(
                          builder: (context, state) {
                            final isLoading = state.status == PatientStatus.loading;
                            return ElevatedButton.icon(
                              onPressed: isLoading ? null : _savePatient,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: azulPetroleo,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                elevation: 0,
                              ),
                              icon: isLoading 
                                  ? const SizedBox(
                                      width: 20, 
                                      height: 20, 
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Icon(
                                      Icons.save_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                              label: Text(
                                isLoading
                                    ? 'Salvando...'
                                    : (isEditing ? 'Salvar Alterações' : 'Cadastrar Paciente'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        BlocBuilder<PatientBloc, PatientState>(
                          builder: (context, state) {
                            final isLoading = state.status == PatientStatus.loading;
                            return ElevatedButton.icon(
                              onPressed: isLoading ? null : _savePatient,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: azulPetroleo,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                              ),
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 20, 
                                      height: 20, 
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Icon(
                                      Icons.save_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                              label: Text(
                                isLoading 
                                    ? 'Salvando...' 
                                    : (isEditing ? 'Salvar Alterações' : 'Cadastrar'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: const Color(0xFF64748B),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
     ),
    );
  }

  Widget _buildTextFieldCard({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
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
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
          prefixIcon: Icon(icon, color: const Color(0xFF0D9488)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  String _translateGender(String gen) {
    if (gen == 'male' || gen == 'masculino') return 'Masculino';
    if (gen == 'female' || gen == 'feminino') return 'Feminino';
    return 'Outros';
  }

  Widget _buildDropdownCard({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
          prefixIcon: Icon(icon, color: const Color(0xFF0D9488)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(_translateGender(e))))
            .toList(),
      ),
    );
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 15) return oldValue;
    
    var text = newValue.text.replaceAll(RegExp(r'\D'), '');
    var formattedText = StringBuffer();
    if (text.isNotEmpty) {
      formattedText.write('(');
      if (text.length > 2) {
        formattedText.write('${text.substring(0, 2)}) ');
        if (text.length > 7) {
           formattedText.write('${text.substring(2, 7)}-${text.substring(7)}');
        } else {
           formattedText.write(text.substring(2));
        }
      } else {
        formattedText.write(text);
      }
    }
    
    return TextEditingValue(
      text: formattedText.toString(),
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 10) return oldValue;
    
    var text = newValue.text.replaceAll(RegExp(r'\D'), '');
    var formattedText = StringBuffer();
    if (text.isNotEmpty) {
      if (text.length > 2) {
        formattedText.write('${text.substring(0, 2)}/');
        if (text.length > 4) {
           formattedText.write('${text.substring(2, 4)}/${text.substring(4)}');
        } else {
           formattedText.write(text.substring(2));
        }
      } else {
        formattedText.write(text);
      }
    }
    
    return TextEditingValue(
      text: formattedText.toString(),
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

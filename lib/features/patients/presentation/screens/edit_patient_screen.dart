import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/core/theme/app_theme.dart';
import 'package:physigest/features/patients/domain/models/patient.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_bloc.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_event.dart';

class EditPatientScreen extends StatefulWidget {
  final Patient? patient;

  const EditPatientScreen({super.key, this.patient});

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _birthDateCtrl;
  late TextEditingController _occupationCtrl;

  // Cores do Padrão PhysiGest
  static const Color azulPetroleo = Color(0xFF004D4D);
  static const Color roxoClaro = Color(0xFF9370DB);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _nameCtrl = TextEditingController(text: widget.patient?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.patient?.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.patient?.phone ?? '');
    _birthDateCtrl = TextEditingController(text: widget.patient?.birthDate ?? '');
    _occupationCtrl = TextEditingController(text: widget.patient?.occupation ?? '');
  }

  @override
  void dispose() {
    _tabController.dispose();
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Prontuário: ${widget.patient!.name}' : 'Novo Paciente',
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: roxoClaro,
          labelColor: azulPetroleo,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
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
          _buildDadosTab(),
          _buildPlaceholderTab(Icons.calendar_month, 'Agendamentos do Paciente'),
          _buildPlaceholderTab(Icons.history_edu, 'Ficha de Anamnese'),
          _buildPlaceholderTab(Icons.account_balance_wallet, 'Histórico Financeiro'),
          _buildPlaceholderTab(Icons.file_present, 'Documentos e Exames'),
          _buildPlaceholderTab(Icons.photo_library, 'Galeria de Fotos (Evolução)'),
        ],
      ),
      // Botão de salvar visível apenas na aba de Dados ou como ação global
      floatingActionButton: _tabController.index == 0 
        ? FloatingActionButton.extended(
            onPressed: _savePatient,
            backgroundColor: azulPetroleo,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Salvar', style: TextStyle(color: Colors.white)),
          )
        : null,
    );
  }

  // ABA 1: DADOS (O código original do formulário)
  Widget _buildDadosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextFieldCard(
                  label: 'Nome Completo',
                  controller: _nameCtrl,
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                _buildTextFieldCard(
                  label: 'E-mail',
                  controller: _emailCtrl,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                Row(
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
                        label: 'Nascimento',
                        controller: _birthDateCtrl,
                        icon: Icons.calendar_today_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextFieldCard(
                  label: 'Profissão',
                  controller: _occupationCtrl,
                  icon: Icons.work_outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Componente Reutilizável de Input (Seu padrão original)
  Widget _buildTextFieldCard({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: azulPetroleo),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),
    );
  }

  // Placeholder para as outras abas
  Widget _buildPlaceholderTab(IconData icon, String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: roxoClaro.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: roxoClaro),
            child: const Text('Adicionar Novo', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
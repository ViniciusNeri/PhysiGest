import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physigest/core/theme/app_theme.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_bloc.dart';
import 'package:physigest/features/patients/presentation/bloc/patient_state.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_bloc.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_state.dart';

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  // 'revenue' (Receita) ou 'expense' (Despesa)
  String _transactionType = 'revenue';

  // Controladores Generais
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // Controladores para Receita
  String? _selectedPatientId;
  String _paymentMethod = 'Pix'; // Valor padrão seguro
  final TextEditingController _revenueTypeController = TextEditingController(
    text: 'Consulta Avulsa',
  );

  // Controladores para Despesa
  String _expenseType = 'Fixa';

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _revenueTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      surfaceTintColor:
          Colors.transparent, // Remove o brilho de material3 sobre a cor
      insetPadding: EdgeInsets.all(isMobile ? 16 : 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // CABEÇALHO DO DIALOG
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Novo Lançamento',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.black45,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Adicione uma nova receita ou despesa ao caixa.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),

                // SEGMENTED CONTROL (Receita vs Despesa)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSegmentButton(
                          title: 'Receita',
                          isActive: _transactionType == 'revenue',
                          activeColor: const Color(0xFF10B981), // Verde Sucesso
                          onTap: () =>
                              setState(() => _transactionType = 'revenue'),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildSegmentButton(
                          title: 'Despesa',
                          isActive: _transactionType == 'expense',
                          activeColor: const Color(0xFFEF4444), // Vermelho Erro
                          onTap: () =>
                              setState(() => _transactionType = 'expense'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // FORMULÁRIO DINÂMICO
                if (_transactionType == 'revenue')
                  _buildRevenueForm()
                else
                  _buildExpenseForm(),

                const SizedBox(height: 40),

                // BOTÕES DE AÇÃO
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _transactionType == 'revenue'
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _transactionType == 'revenue'
                            ? 'Salvar Receita'
                            : 'Salvar Despesa',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? activeColor : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueForm() {
    return BlocBuilder<PatientBloc, PatientState>(
      builder: (context, patientState) {
        return BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            final paymentMethods = _getAvailablePaymentMethods(settingsState, isRevenue: true);
            
            // Sincronizar _paymentMethod com a primeira opção se estiver vazio ou inválido
            if (_paymentMethod.isEmpty || !paymentMethods.contains(_paymentMethod)) {
               _paymentMethod = paymentMethods.first;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPatientSelector(patientState),
                const SizedBox(height: 20),
                // Mostrar campo de descrição para receitas apenas se nenhum paciente estiver selecionado
                if (_selectedPatientId == null) ...[
                  _buildInputField(
                    label: 'Descrição / Beneficiário',
                    hint: 'Ex: Venda de Produto, Outros...',
                    controller: _descriptionController,
                    icon: Icons.info_outline_rounded,
                  ),
                  const SizedBox(height: 20),
                ],
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildInputField(
                        label: 'Valor (R\$)',
                        hint: '0,00',
                        controller: _amountController,
                        icon: Icons.attach_money_rounded,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: _buildDropdown(
                        label: 'Forma de Pagamento',
                        value: _paymentMethod,
                        items: paymentMethods,
                        onChanged: (val) =>
                            setState(() => _paymentMethod = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Plano / Tipo de Cobrança',
                  hint: 'Ex: Mensalidade, Consulta Avulsa...',
                  controller: _revenueTypeController,
                  icon: Icons.assignment_outlined,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPatientSelector(PatientState state) {
    if (state.status == PatientStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final patients = state.patients;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Paciente'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: (patients.any((p) => p.id == _selectedPatientId))
                  ? _selectedPatientId
                  : null,
              hint: const Text(
                'Selecione um paciente',
                style: TextStyle(color: Colors.black26, fontSize: 14),
              ),
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF94A3B8),
              ),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    'Outros (Sem Paciente)',
                    style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.normal),
                  ),
                ),
                ...patients.map((p) {
                  return DropdownMenuItem<String>(
                    value: p.id,
                    child: Text(p.name),
                  );
                }),
              ],
              onChanged: (val) => setState(() => _selectedPatientId = val),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseForm() {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final paymentMethods = _getAvailablePaymentMethods(settingsState, isRevenue: false);

        // Sincronizar _paymentMethod com a primeira opção se estiver vazio ou inválido
        if (_paymentMethod.isEmpty || !paymentMethods.contains(_paymentMethod)) {
          _paymentMethod = paymentMethods.first;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField(
              label: 'Descrição da Despesa',
              hint: 'Ex: Conta de Luz, Materiais...',
              controller: _descriptionController,
              icon: Icons.receipt_long_rounded,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildInputField(
                    label: 'Valor (R\$)',
                    hint: '0,00',
                    controller: _amountController,
                    icon: Icons.money_off_csred_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: _buildDropdown(
                    label: 'Forma de Pagamento',
                    value: _paymentMethod,
                    items: paymentMethods,
                    onChanged: (val) => setState(() => _paymentMethod = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDropdown(
              label: 'Tipo de Despesa',
              value: _expenseType,
              items: ['Fixa', 'Variável'],
              onChanged: (val) => setState(() => _expenseType = val!),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // COMPONENTES ÚTEIS
  // ==========================================
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor,
                width: 1.5,
              ),
            ),
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF94A3B8),
              ),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  void _saveTransaction() {
    final amountText = _amountController.text.replaceAll(r'R$', '').replaceAll('.', '').replaceAll(',', '.').trim();
    final amount = double.tryParse(amountText) ?? 0.0;
    final description = _descriptionController.text;

    if (_transactionType == 'revenue') {
      if (_selectedPatientId == null && description.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Descreva a origem da receita ou selecione um paciente.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }
    } else {
      if (description.isEmpty || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preencha a descrição e um valor válido.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }
    }

    // Retorna os dados mapeados para o FinancialBloc via FinancialScreen
    Navigator.of(context).pop({
      'type': _transactionType, // 'revenue' ou 'expense'
      'patientId': _selectedPatientId,
      'description': _transactionType == 'revenue' 
          ? (description.isEmpty ? 'Receita Avulsa' : description)
          : description,
      'amount': amount,
      'paymentMethod': _paymentMethod,
      'category': _transactionType == 'revenue' ? 'Outros' : description, 
      'expenseType': _transactionType == 'expense' 
          ? (_expenseType == 'Fixa' ? 'fixed' : 'variable')
          : null,
    });
  }

  List<String> _getAvailablePaymentMethods(SettingsState state,
      {required bool isRevenue}) {
    if (state is SettingsLoaded && state.paymentMethods.isNotEmpty) {
      final names = state.paymentMethods
          .map((e) => e.name.trim())
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList();

      if (names.isNotEmpty) return names;
    }

    // Fallbacks consistentes
    return isRevenue
        ? ['Dinheiro', 'Débito', 'Crédito', 'Pix', 'Transferência']
        : ['Dinheiro', 'Débito', 'Crédito', 'Pix', 'Boleto'];
  }
}

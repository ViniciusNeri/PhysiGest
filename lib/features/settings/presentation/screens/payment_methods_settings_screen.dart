import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physigest/core/theme/app_theme.dart';
import 'package:physigest/features/settings/domain/entities/payment_method.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_bloc.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_event.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_state.dart';
import 'package:physigest/core/widgets/app_error_view.dart';
import 'package:physigest/core/utils/app_alerts.dart';

class PaymentMethodsSettingsScreen extends StatelessWidget {
  const PaymentMethodsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Formas de Pagamento',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: BlocListener<SettingsBloc, SettingsState>(
            listener: (context, state) {
              if (state is SettingsError) {
                AppAlerts.error(context, state.message);
              } else if (state.successMessage != null && (ModalRoute.of(context)?.isCurrent ?? false)) {
                AppAlerts.success(context, state.successMessage!);
                context.read<SettingsBloc>().add(ClearSettingsMessage());
              }
            },
            child: BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                if (state is SettingsError) {
                  return AppErrorView(
                    message: state.message,
                    onRetry: () => context.read<SettingsBloc>().add(LoadSettings()),
                  );
                }

                if (state is SettingsLoaded) {
                  final methods = state.paymentMethods;

                  if (methods.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma forma de pagamento cadastrada.'),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    itemCount: methods.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final method = methods[index];
                      return _PaymentTile(method: method);
                    },
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Novo Pagamento', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          _showPaymentDialog(context);
        },
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, [PaymentMethod? method]) {
    showDialog(
      context: context,
      builder: (ctx) => _PaymentDialog(method: method, blocContext: context),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final PaymentMethod method;

  const _PaymentTile({required this.method});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: method.isActive ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.payments_outlined,
            color: method.isActive ? AppTheme.primaryColor : Colors.grey,
          ),
        ),
        title: Text(
          method.name,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: method.isActive ? const Color(0xFF0F172A) : Colors.grey,
            decoration: method.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Container(
          margin: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: method.isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  method.isActive ? 'Ativo' : 'Inativo',
                  style: TextStyle(
                    color: method.isActive ? Colors.green.shade700 : Colors.red.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: Switch(
          value: method.isActive,
          activeThumbColor: AppTheme.primaryColor,
          onChanged: (val) {
            final updated = method.copyWith(isActive: val);
            context.read<SettingsBloc>().add(UpdatePaymentMethod(updated));
          },
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) =>
                _PaymentDialog(method: method, blocContext: context),
          );
        },
      ),
    );
  }
}

class _PaymentDialog extends StatefulWidget {
  final PaymentMethod? method;
  final BuildContext blocContext;

  const _PaymentDialog({this.method, required this.blocContext});

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.method != null) {
      _controller.text = widget.method!.name;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.method != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(32.0),
        constraints: const BoxConstraints(maxWidth: 450),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    isEditing ? 'Editar Pagamento' : 'Novo Pagamento',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _controller,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Nome da Forma de Pagamento',
                  hintText: 'Ex: Cartão de Crédito',
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final name = _controller.text.trim();
                        if (isEditing) {
                          widget.blocContext.read<SettingsBloc>().add(
                            UpdatePaymentMethod(
                              widget.method!.copyWith(name: name),
                            ),
                          );
                        } else {
                          widget.blocContext.read<SettingsBloc>().add(
                            AddPaymentMethod(name),
                          );
                        }
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(isEditing ? 'Atualizar' : 'Criar Pagamento', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

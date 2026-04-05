import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physigest/core/theme/app_theme.dart';
import 'package:physigest/features/settings/domain/entities/payment_method.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_bloc.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_event.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_state.dart';
import 'package:physigest/core/widgets/app_error_view.dart';

class PaymentMethodsSettingsScreen extends StatelessWidget {
  const PaymentMethodsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Formas de Pagamento',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
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
              padding: const EdgeInsets.all(16),
              itemCount: methods.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final method = methods[index];
                return _PaymentTile(method: method);
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white),
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          method.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: method.isActive ? const Color(0xFF0F172A) : Colors.grey,
            decoration: method.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(
          method.isActive ? 'Ativo' : 'Inativo',
          style: TextStyle(
            color: method.isActive ? Colors.green : Colors.red,
            fontSize: 12,
            fontWeight: FontWeight.w600,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Editar Pagamento' : 'Novo Pagamento',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Nome da Forma de Pagamento',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
                    child: const Text('Salvar'),
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

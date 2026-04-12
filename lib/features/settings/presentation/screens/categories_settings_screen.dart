import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:physigest/core/theme/app_theme.dart';
import 'package:physigest/features/settings/domain/entities/attendance_category.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_bloc.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_event.dart';
import 'package:physigest/features/settings/presentation/bloc/settings/settings_state.dart';
import 'package:physigest/core/widgets/app_error_view.dart';
import 'package:physigest/core/utils/app_alerts.dart';

class CategoriesSettingsScreen extends StatelessWidget {
  const CategoriesSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Categorias de Atendimento',
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
                  final categories = state.categories;

                  if (categories.isEmpty) {
                    return const Center(child: Text('Nenhuma categoria cadastrada.'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _CategoryTile(category: category);
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
        label: const Text('Nova Categoria', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          _showCategoryDialog(context);
        },
      ),
    );
  }

  void _showCategoryDialog(
    BuildContext context, [
    AttendanceCategory? category,
  ]) {
    showDialog(
      context: context,
      builder: (ctx) =>
          _CategoryDialog(category: category, blocContext: context),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final AttendanceCategory category;

  const _CategoryTile({required this.category});

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
            color: category.isActive ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.medical_services_outlined,
            color: category.isActive ? AppTheme.primaryColor : Colors.grey,
          ),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: category.isActive ? const Color(0xFF0F172A) : Colors.grey,
            decoration: category.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.timer_outlined, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              '${category.duration} minutos',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: category.isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                category.isActive ? 'Ativo' : 'Inativo',
                style: TextStyle(
                  color: category.isActive ? Colors.green.shade700 : Colors.red.shade700,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Switch(
          value: category.isActive,
          activeThumbColor: AppTheme.primaryColor,
          onChanged: (val) {
            final updated = category.copyWith(isActive: val);
            context.read<SettingsBloc>().add(UpdateAttendanceCategory(updated));
          },
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) =>
                _CategoryDialog(category: category, blocContext: context),
          );
        },
      ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  final AttendanceCategory? category;
  final BuildContext blocContext;

  const _CategoryDialog({this.category, required this.blocContext});

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _durationController.text = widget.category!.duration.toString();
    } else {
      _durationController.text = '60';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

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
                    child: const Icon(Icons.category_rounded, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    isEditing ? 'Editar Categoria' : 'Nova Categoria',
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
                controller: _nameController,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Nome da Categoria',
                  hintText: 'Ex: Fisioterapia Esportiva',
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
              const SizedBox(height: 20),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Duração (minutos)',
                  hintText: 'Ex: 45',
                  prefixIcon: const Icon(Icons.timer_outlined),
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
                  suffixText: 'min',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Campo obrigatório';
                  }
                  if (int.tryParse(val) == null) {
                    return 'Informe um número';
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
                        final name = _nameController.text.trim();
                        final duration = int.parse(_durationController.text);
                        if (isEditing) {
                          widget.blocContext.read<SettingsBloc>().add(
                            UpdateAttendanceCategory(
                              widget.category!.copyWith(
                                name: name,
                                duration: duration,
                              ),
                            ),
                          );
                        } else {
                          widget.blocContext.read<SettingsBloc>().add(
                            AddAttendanceCategory(
                              name: name,
                              duration: duration,
                            ),
                          );
                        }
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(isEditing ? 'Atualizar' : 'Criar Categoria', style: const TextStyle(fontWeight: FontWeight.bold)),
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

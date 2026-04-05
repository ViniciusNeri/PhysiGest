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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Categorias',
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
      body: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsError) {
            AppAlerts.error(context, state.message);
          } else if (state.successMessage != null) {
            AppAlerts.success(context, state.successMessage!);
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
                padding: const EdgeInsets.all(16),
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white),
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
          category.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: category.isActive ? const Color(0xFF0F172A) : Colors.grey,
            decoration: category.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(
          category.isActive ? 'Ativo' : 'Inativo',
          style: TextStyle(
            color: category.isActive ? Colors.green : Colors.red,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
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
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _controller.text = widget.category!.name;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

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
                isEditing ? 'Editar Categoria' : 'Nova Categoria',
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
                  labelText: 'Nome da Categoria',
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
                            UpdateAttendanceCategory(
                              widget.category!.copyWith(name: name),
                            ),
                          );
                        } else {
                          widget.blocContext.read<SettingsBloc>().add(
                            AddAttendanceCategory(name),
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

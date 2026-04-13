import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:physigest/features/patients/domain/models/patient.dart';
import 'package:physigest/features/patients/domain/models/patient_attachment.dart';
import 'package:physigest/core/utils/app_alerts.dart';
import '../bloc/patient_attachment_bloc.dart';
import '../bloc/patient_attachment_event.dart';
import '../bloc/patient_attachment_state.dart';

class PatientAttachmentView extends StatelessWidget {
  final Patient patient;

  const PatientAttachmentView({super.key, required this.patient});

  static const Color _primary = Color(0xFF7C3AED);
  static const Color _textMain = Color(0xFF1E293B);
  static const Color _textSub = Color(0xFF94A3B8);
  static const Color _border = Color(0xFFE2E8F0);
  static const Color _bg = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PatientAttachmentBloc, PatientAttachmentState>(
      listener: (ctx, state) {
        if (state.status == AttachmentStatus.failure && state.errorMessage != null) {
          AppAlerts.error(ctx, state.errorMessage!);
          ctx.read<PatientAttachmentBloc>().add(ClearAttachmentMessage());
        } else if (state.status == AttachmentStatus.success && state.successMessage != null) {
          AppAlerts.success(ctx, state.successMessage!);
          ctx.read<PatientAttachmentBloc>().add(ClearAttachmentMessage());
        }
      },
      builder: (ctx, state) {
        return Scaffold(
          backgroundColor: _bg,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showUploadDialog(ctx),
            backgroundColor: _primary,
            icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
            label: const Text('ANEXAR ARQUIVO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: _buildBody(ctx, state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PatientAttachmentState state) {
    if (state.status == AttachmentStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == AttachmentStatus.uploading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: _primary),
            const SizedBox(height: 16),
            Text('Enviando arquivo…', style: TextStyle(color: _textSub, fontSize: 14)),
          ],
        ),
      );
    }

    if (state.attachments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_rounded, size: 72, color: _textSub.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text('Nenhum anexo encontrado', style: TextStyle(color: _textSub, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Clique em ANEXAR ARQUIVO para adicionar documentos', style: TextStyle(color: _textSub, fontSize: 13)),
          ],
        ),
      );
    }

    // Group by category
    final Map<String, List<PatientAttachment>> grouped = {};
    for (final a in state.attachments) {
      grouped.putIfAbsent(a.displayCategory, () => []).add(a);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                entry.key.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: _textSub,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Column(
                children: entry.value.asMap().entries.map((e) {
                  final isLast = e.key == entry.value.length - 1;
                  return Column(
                    children: [
                      _AttachmentTile(
                        attachment: e.value,
                        patientId: patient.id,
                      ),
                      if (!isLast) const Divider(height: 1, indent: 72, color: _border),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  void _showUploadDialog(BuildContext context) {
    final bloc = context.read<PatientAttachmentBloc>();
    String selectedCategory = 'exams';
    String description = '';

    showDialog(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (ctx, setDlgState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Anexar Arquivo', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: _textMain)),
                      IconButton(
                        onPressed: () => Navigator.pop(dlgCtx),
                        icon: const Icon(Icons.close, color: _textSub, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Categoria', style: TextStyle(fontWeight: FontWeight.bold, color: _textMain, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'exams', child: Text('Exames')),
                      DropdownMenuItem(value: 'medical_records', child: Text('Prontuário')),
                      DropdownMenuItem(value: 'prescriptions', child: Text('Prescrições')),
                      DropdownMenuItem(value: 'photos', child: Text('Fotos')),
                      DropdownMenuItem(value: 'documents', child: Text('Documentos')),
                      DropdownMenuItem(value: 'other', child: Text('Outros')),
                    ],
                    onChanged: (val) => setDlgState(() => selectedCategory = val!),
                  ),
                  const SizedBox(height: 16),
                  const Text('Descrição (opcional)', style: TextStyle(fontWeight: FontWeight.bold, color: _textMain, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextFormField(
                    onChanged: (val) => description = val,
                    decoration: InputDecoration(
                      hintText: 'Ex: Resultado de hemograma completo',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  Text('Limite: 10MB. Formatos aceitos: PDF, imagens, documentos.', style: TextStyle(color: _textSub, fontSize: 11)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(dlgCtx);
                        final result = await FilePicker.pickFiles(
                          allowMultiple: false,
                          withData: true,
                        );
                        if (result != null && result.files.isNotEmpty) {
                          final file = result.files.first;
                          final bytes = file.bytes;
                          if (bytes == null) {
                            if (context.mounted) AppAlerts.error(context, 'Não foi possível ler os dados do arquivo.');
                            return;
                          }
                          final sizeMb = (file.size) / (1024 * 1024);
                          if (sizeMb > 10) {
                            if (context.mounted) AppAlerts.error(context, 'O arquivo excede o limite de 10MB.');
                            return;
                          }
                          bloc.add(UploadAttachment(
                            patientId: patient.id,
                            fileBytes: bytes,
                            fileName: file.name,
                            mimeType: _mimeFromExtension(file.extension),
                            category: selectedCategory,
                            description: description,
                          ));
                        }
                      },
                      icon: const Icon(Icons.folder_open_rounded, color: Colors.white),
                      label: const Text('SELECIONAR ARQUIVO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _mimeFromExtension(String? ext) {
    switch (ext?.toLowerCase()) {
      case 'pdf': return 'application/pdf';
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'png': return 'image/png';
      case 'doc': return 'application/msword';
      case 'docx': return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default: return 'application/octet-stream';
    }
  }
}

class _AttachmentTile extends StatelessWidget {
  final PatientAttachment attachment;
  final String patientId;

  const _AttachmentTile({required this.attachment, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _FileIcon(fileType: attachment.fileType),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.originalName,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B), fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (attachment.description.isNotEmpty)
                  Text(
                    attachment.description,
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  '${attachment.displaySize} · ${_formatDate(attachment.uploadedAt)}',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            color: const Color(0xFF7C3AED),
            tooltip: 'Abrir',
            onPressed: () => _open(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            color: Colors.red.shade400,
            tooltip: 'Excluir',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context) async {
    final url = Uri.tryParse(attachment.filePath);
    if (url == null) return;
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) AppAlerts.error(context, 'Não foi possível abrir o arquivo.');
    }
  }

  void _confirmDelete(BuildContext context) {
    final bloc = context.read<PatientAttachmentBloc>();
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir Anexo?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Deseja remover permanentemente "${attachment.originalName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dlgCtx);
              bloc.add(DeleteAttachment(patientId: patientId, attachmentId: attachment.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso.split('Z')[0]);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return iso;
    }
  }
}

class _FileIcon extends StatelessWidget {
  final String fileType;
  const _FileIcon({required this.fileType});

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color color;

    if (fileType == 'application/pdf') {
      icon = Icons.picture_as_pdf_rounded;
      color = Colors.red;
    } else if (fileType.startsWith('image/')) {
      icon = Icons.image_rounded;
      color = Colors.blue;
    } else if (fileType.contains('word')) {
      icon = Icons.description_rounded;
      color = Colors.indigo;
    } else {
      icon = Icons.insert_drive_file_rounded;
      color = Colors.grey;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

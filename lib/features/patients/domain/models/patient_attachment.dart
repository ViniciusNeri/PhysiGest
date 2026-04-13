import 'package:equatable/equatable.dart';

class PatientAttachment extends Equatable {
  final String id;
  final String patientId;
  final String userId;
  final String fileName;
  final String originalName;
  final String fileType;
  final int fileSize;
  final String filePath;
  final String category;
  final String description;
  final List<String> tags;
  final String uploadedAt;

  const PatientAttachment({
    required this.id,
    required this.patientId,
    required this.userId,
    required this.fileName,
    required this.originalName,
    required this.fileType,
    required this.fileSize,
    required this.filePath,
    required this.category,
    this.description = '',
    this.tags = const [],
    required this.uploadedAt,
  });

  String get displayCategory {
    switch (category) {
      case 'exams': return 'Exames';
      case 'medical_records': return 'Prontuário';
      case 'prescriptions': return 'Prescrições';
      case 'photos': return 'Fotos';
      case 'documents': return 'Documentos';
      default: return 'Outros';
    }
  }

  String get displaySize {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  bool get isPdf => fileType == 'application/pdf';
  bool get isImage => fileType.startsWith('image/');

  @override
  List<Object?> get props => [id, patientId, fileName, fileType, category, uploadedAt];
}

import '../../domain/models/patient_attachment.dart';

class PatientAttachmentModel extends PatientAttachment {
  const PatientAttachmentModel({
    required super.id,
    required super.patientId,
    required super.userId,
    required super.fileName,
    required super.originalName,
    required super.fileType,
    required super.fileSize,
    required super.filePath,
    required super.category,
    super.description,
    super.tags,
    required super.uploadedAt,
  });

  factory PatientAttachmentModel.fromJson(Map<String, dynamic> json) {
    return PatientAttachmentModel(
      id: json['id'] ?? json['_id'] ?? '',
      patientId: json['patientId'] ?? '',
      userId: json['userId'] ?? '',
      fileName: json['fileName'] ?? '',
      originalName: json['originalName'] ?? json['fileName'] ?? '',
      fileType: json['fileType'] ?? json['mimeType'] ?? '',
      fileSize: (json['fileSize'] ?? json['size'] ?? 0) as int,
      filePath: json['filePath'] ?? json['path'] ?? '',
      category: json['category'] ?? 'other',
      description: json['description'] ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      uploadedAt: json['uploadedAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }
}

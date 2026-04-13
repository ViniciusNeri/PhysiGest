import 'package:equatable/equatable.dart';

abstract class PatientAttachmentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAttachments extends PatientAttachmentEvent {
  final String patientId;
  LoadAttachments(this.patientId);
  @override
  List<Object?> get props => [patientId];
}

class UploadAttachment extends PatientAttachmentEvent {
  final String patientId;
  final List<int> fileBytes;
  final String fileName;
  final String mimeType;
  final String category;
  final String description;

  UploadAttachment({
    required this.patientId,
    required this.fileBytes,
    required this.fileName,
    required this.mimeType,
    required this.category,
    this.description = '',
  });

  @override
  List<Object?> get props => [patientId, fileBytes, fileName, category];
}

class DeleteAttachment extends PatientAttachmentEvent {
  final String patientId;
  final String attachmentId;
  DeleteAttachment({required this.patientId, required this.attachmentId});
  @override
  List<Object?> get props => [patientId, attachmentId];
}

class ClearAttachmentMessage extends PatientAttachmentEvent {}

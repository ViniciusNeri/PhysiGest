import 'package:equatable/equatable.dart';
import 'package:physigest/features/patients/domain/models/patient_attachment.dart';

enum AttachmentStatus { initial, loading, success, uploading, failure }

class PatientAttachmentState extends Equatable {
  final AttachmentStatus status;
  final List<PatientAttachment> attachments;
  final String? successMessage;
  final String? errorMessage;

  const PatientAttachmentState({
    this.status = AttachmentStatus.initial,
    this.attachments = const [],
    this.successMessage,
    this.errorMessage,
  });

  PatientAttachmentState copyWith({
    AttachmentStatus? status,
    List<PatientAttachment>? attachments,
    String? successMessage,
    String? errorMessage,
    bool clearMessage = false,
  }) {
    return PatientAttachmentState(
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
      successMessage: clearMessage ? null : (successMessage ?? this.successMessage),
      errorMessage: clearMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, attachments, successMessage, errorMessage];
}

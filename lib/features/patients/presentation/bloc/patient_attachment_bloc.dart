import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:physigest/features/patients/data/datasources/patient_remote_datasource.dart';
import 'patient_attachment_event.dart';
import 'patient_attachment_state.dart';

@injectable
class PatientAttachmentBloc extends Bloc<PatientAttachmentEvent, PatientAttachmentState> {
  final IPatientRemoteDataSource _dataSource;

  PatientAttachmentBloc(this._dataSource) : super(const PatientAttachmentState()) {
    on<LoadAttachments>(_onLoad);
    on<UploadAttachment>(_onUpload);
    on<DeleteAttachment>(_onDelete);
    on<ClearAttachmentMessage>((event, emit) {
      emit(state.copyWith(status: AttachmentStatus.success, clearMessage: true));
    });
  }

  Future<void> _onLoad(LoadAttachments event, Emitter<PatientAttachmentState> emit) async {
    emit(state.copyWith(status: AttachmentStatus.loading, clearMessage: true));
    try {
      final attachments = await _dataSource.getAttachments(event.patientId);
      emit(state.copyWith(status: AttachmentStatus.success, attachments: attachments));
    } catch (e) {
      emit(state.copyWith(
        status: AttachmentStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onUpload(UploadAttachment event, Emitter<PatientAttachmentState> emit) async {
    emit(state.copyWith(status: AttachmentStatus.uploading, clearMessage: true));
    try {
      final attachment = await _dataSource.uploadAttachment(
        event.patientId,
        event.fileBytes,
        event.fileName,
        event.mimeType,
        event.category,
        event.description,
      );
      emit(state.copyWith(
        status: AttachmentStatus.success,
        attachments: [...state.attachments, attachment],
        successMessage: 'Arquivo anexado com sucesso!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AttachmentStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onDelete(DeleteAttachment event, Emitter<PatientAttachmentState> emit) async {
    emit(state.copyWith(status: AttachmentStatus.loading, clearMessage: true));
    try {
      await _dataSource.deleteAttachment(event.patientId, event.attachmentId);
      final updated = state.attachments.where((a) => a.id != event.attachmentId).toList();
      emit(state.copyWith(
        status: AttachmentStatus.success,
        attachments: updated,
        successMessage: 'Arquivo removido com sucesso!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AttachmentStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}

import 'package:equatable/equatable.dart';
import '../../domain/models/patient.dart';

enum AnamnesisStatus { initial, loading, empty, success, failure, saving, saveSuccess }

class AnamnesisState extends Equatable {
  final AnamnesisStatus status;
  final Anamnesis? anamnesis;
  final String? errorMessage;
  final String? successMessage;

  const AnamnesisState({
    this.status = AnamnesisStatus.initial,
    this.anamnesis,
    this.errorMessage,
    this.successMessage,
  });

  AnamnesisState copyWith({
    AnamnesisStatus? status,
    Anamnesis? anamnesis,
    String? errorMessage,
    String? successMessage,
  }) {
    return AnamnesisState(
      status: status ?? this.status,
      anamnesis: anamnesis ?? this.anamnesis,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [status, anamnesis, errorMessage, successMessage];
}

import 'package:equatable/equatable.dart';
import '../../domain/models/patient.dart';

enum AnamnesisStatus { initial, loading, empty, success, failure, saving, saveSuccess }

class AnamnesisState extends Equatable {
  final AnamnesisStatus status;
  final Anamnesis? anamnesis;
  final String? errorMessage;

  const AnamnesisState({
    this.status = AnamnesisStatus.initial,
    this.anamnesis,
    this.errorMessage,
  });

  AnamnesisState copyWith({
    AnamnesisStatus? status,
    Anamnesis? anamnesis,
    String? errorMessage,
  }) {
    return AnamnesisState(
      status: status ?? this.status,
      anamnesis: anamnesis ?? this.anamnesis,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, anamnesis, errorMessage];
}

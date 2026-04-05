import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/patient_usecases.dart';
import 'anamnesis_event.dart';
import 'anamnesis_state.dart';

@injectable
class AnamnesisBloc extends Bloc<AnamnesisEvent, AnamnesisState> {
  final GetLatestAnamnesisUseCase _getLatestAnamnesisUseCase;
  final CreateAnamnesisUseCase _createAnamnesisUseCase;
  final UpdateAnamnesisUseCase _updateAnamnesisUseCase;

  AnamnesisBloc(
    this._getLatestAnamnesisUseCase,
    this._createAnamnesisUseCase,
    this._updateAnamnesisUseCase,
  ) : super(const AnamnesisState()) {
    on<LoadAnamnesis>(_onLoadAnamnesis);
    on<SaveAnamnesis>(_onSaveAnamnesis);
  }

  Future<void> _onLoadAnamnesis(
    LoadAnamnesis event,
    Emitter<AnamnesisState> emit,
  ) async {
    emit(state.copyWith(status: AnamnesisStatus.loading));
    try {
      final anamnesis = await _getLatestAnamnesisUseCase(event.patientId);
      if (anamnesis == null) {
        emit(state.copyWith(status: AnamnesisStatus.empty));
      } else {
        emit(state.copyWith(status: AnamnesisStatus.success, anamnesis: anamnesis));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AnamnesisStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onSaveAnamnesis(
    SaveAnamnesis event,
    Emitter<AnamnesisState> emit,
  ) async {
    emit(state.copyWith(status: AnamnesisStatus.saving));
    try {
      final currentAnamnesis = state.anamnesis;
      
      // Se não temos anamnese ou o ID está vazio, criamos uma nova (POST)
      if (currentAnamnesis == null || currentAnamnesis.id.isEmpty) {
        final newAnamnesis = await _createAnamnesisUseCase(event.patientId, event.anamnesis);
        emit(state.copyWith(
          status: AnamnesisStatus.saveSuccess,
          anamnesis: newAnamnesis,
          successMessage: 'Anamnese criada com sucesso!',
        ));
      } else {
        // Se já existe, atualizamos (PUT usando o ID existente)
        final updatedAnamnesis = await _updateAnamnesisUseCase(
          event.patientId,
          currentAnamnesis.id,
          event.anamnesis,
        );
        emit(state.copyWith(
          status: AnamnesisStatus.saveSuccess,
          anamnesis: updatedAnamnesis,
          successMessage: 'Anamnese atualizada com sucesso!',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: AnamnesisStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:physigest/features/patients/data/datasources/patient_remote_datasource.dart';
import 'agenda_event.dart';
import 'agenda_state.dart';

@injectable
class AgendaBloc extends Bloc<AgendaEvent, AgendaState> {
  final IPatientRemoteDataSource _dataSource;

  AgendaBloc(this._dataSource) : super(const AgendaState()) {
    on<LoadAgenda>(_onLoadAgenda);
  }

  Future<void> _onLoadAgenda(LoadAgenda event, Emitter<AgendaState> emit) async {
    emit(state.copyWith(status: AgendaStatus.loading));
    try {
      final appointments = await _dataSource.getPatientAgenda(event.patientId);
      emit(state.copyWith(status: AgendaStatus.success, appointments: appointments));
    } catch (e) {
      emit(state.copyWith(
        status: AgendaStatus.failure,
        errorMessage: 'Erro ao carregar agenda: ${e.toString()}',
      ));
    }
  }
}

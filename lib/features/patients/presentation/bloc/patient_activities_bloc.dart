import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/models/patient_activity.dart';
import '../../domain/usecases/patient_usecases.dart';

// EVENTS
abstract class PatientActivitiesEvent extends Equatable {
  const PatientActivitiesEvent();
  @override
  List<Object> get props => [];
}

class LoadPatientActivities extends PatientActivitiesEvent {
  final String patientId;
  const LoadPatientActivities(this.patientId);
  @override
  List<Object> get props => [patientId];
}

// STATES
enum PatientActivitiesStatus { initial, loading, success, failure }

class PatientActivitiesState extends Equatable {
  final List<PatientActivity> activities;
  final PatientActivitiesStatus status;
  final String? errorMessage;

  const PatientActivitiesState({
    this.activities = const [],
    this.status = PatientActivitiesStatus.initial,
    this.errorMessage,
  });

  PatientActivitiesState copyWith({
    List<PatientActivity>? activities,
    PatientActivitiesStatus? status,
    String? errorMessage,
  }) {
    return PatientActivitiesState(
      activities: activities ?? this.activities,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [activities, status, errorMessage];
}

// BLOC
@injectable
class PatientActivitiesBloc extends Bloc<PatientActivitiesEvent, PatientActivitiesState> {
  final GetPatientActivitiesUseCase getPatientActivities;

  PatientActivitiesBloc(this.getPatientActivities) : super(const PatientActivitiesState()) {
    on<LoadPatientActivities>(_onLoadActivities);
  }

  Future<void> _onLoadActivities(
    LoadPatientActivities event,
    Emitter<PatientActivitiesState> emit,
  ) async {
    emit(state.copyWith(status: PatientActivitiesStatus.loading));
    try {
      final activities = await getPatientActivities(event.patientId);
      emit(state.copyWith(
        status: PatientActivitiesStatus.success,
        activities: activities,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PatientActivitiesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}

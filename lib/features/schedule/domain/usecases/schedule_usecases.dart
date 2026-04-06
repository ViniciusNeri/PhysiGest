import 'package:injectable/injectable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';
import 'package:physigest/features/schedule/domain/models/agenda_lock.dart';
import '../repositories/i_schedule_repository.dart';

@lazySingleton
class GetAppointmentsUseCase {
  final IScheduleRepository repository;
  GetAppointmentsUseCase(this.repository);
  Future<List<Appointment>> call() => repository.getAppointments();
}

@lazySingleton
class CreateAppointmentUseCase {
  final IScheduleRepository repository;
  CreateAppointmentUseCase(this.repository);
  Future<Appointment> call(Appointment appointment) =>
      repository.createAppointment(appointment);
}

@lazySingleton
class UpdateAppointmentUseCase {
  final IScheduleRepository repository;
  UpdateAppointmentUseCase(this.repository);
  Future<Appointment> call(Appointment appointment) =>
      repository.updateAppointment(appointment);
}

@lazySingleton
class DeleteAppointmentUseCase {
  final IScheduleRepository repository;
  DeleteAppointmentUseCase(this.repository);
  Future<void> call(String id) => repository.deleteAppointment(id);
}

@lazySingleton
class GetAvailablePatientsUseCase {
  final IScheduleRepository repository;
  GetAvailablePatientsUseCase(this.repository);
  Future<List<Map<String, dynamic>>> call() => repository.getAvailablePatients();
}

@lazySingleton
class GetCategoriesUseCase {
  final IScheduleRepository repository;
  GetCategoriesUseCase(this.repository);
  Future<List<Map<String, dynamic>>> call() => repository.getCategories();
}

@lazySingleton
class GetAgendaLocksUseCase {
  final IScheduleRepository repository;
  GetAgendaLocksUseCase(this.repository);
  Future<List<AgendaLock>> call() => repository.getAgendaLocks();
}

@lazySingleton
class CreateAgendaLockUseCase {
  final IScheduleRepository repository;
  CreateAgendaLockUseCase(this.repository);
  Future<AgendaLock> call(AgendaLock lock) => repository.createAgendaLock(lock);
}

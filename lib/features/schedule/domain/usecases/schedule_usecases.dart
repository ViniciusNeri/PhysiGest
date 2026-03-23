import 'package:injectable/injectable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';
import '../repositories/i_schedule_repository.dart';

@lazySingleton
class GetAppointmentsUseCase {
  final IScheduleRepository repository;
  GetAppointmentsUseCase(this.repository);
  Future<List<Appointment>> call(DateTime from, DateTime to) =>
      repository.getAppointments(from, to);
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
  Future<List<String>> call() => repository.getAvailablePatients();
}

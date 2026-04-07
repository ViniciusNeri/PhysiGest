import 'package:injectable/injectable.dart';
import 'package:physigest/features/schedule/domain/models/appointment.dart';
import 'package:physigest/features/schedule/domain/models/agenda_lock.dart';
import '../../domain/repositories/i_schedule_repository.dart';
import '../datasources/schedule_remote_datasource.dart';

@LazySingleton(as: IScheduleRepository)
class ScheduleRepositoryImpl implements IScheduleRepository {
  final IScheduleRemoteDataSource remoteDataSource;

  ScheduleRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Appointment>> getAppointments() async {
    return await remoteDataSource.getAppointments();
  }

  @override
  Future<Appointment> createAppointment(Appointment appointment) async {
    return await remoteDataSource.createAppointment(appointment);
  }

  @override
  Future<Appointment> updateAppointment(Appointment appointment) async {
    return await remoteDataSource.updateAppointment(appointment);
  }

  @override
  Future<void> deleteAppointment(String id) async {
    return await remoteDataSource.deleteAppointment(id);
  }

  @override
  Future<List<Map<String, dynamic>>> getAvailablePatients() async {
    return await remoteDataSource.getAvailablePatients();
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    return await remoteDataSource.getCategories();
  }

  @override
  Future<List<AgendaLock>> getAgendaLocks() async {
    return await remoteDataSource.getAgendaLocks();
  }

  @override
  Future<AgendaLock> createAgendaLock(AgendaLock lock) async {
    return await remoteDataSource.createAgendaLock(lock);
  }

  @override
  Future<void> deleteAgendaLock(String id) async {
    return await remoteDataSource.deleteAgendaLock(id);
  }
}

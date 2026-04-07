import 'package:physigest/features/schedule/domain/models/appointment.dart';
import 'package:physigest/features/schedule/domain/models/agenda_lock.dart';

abstract class IScheduleRepository {
  Future<List<Appointment>> getAppointments();
  Future<Appointment> createAppointment(Appointment appointment);
  Future<Appointment> updateAppointment(Appointment appointment);
  Future<void> deleteAppointment(String id);
  Future<List<Map<String, dynamic>>> getAvailablePatients();
  Future<List<Map<String, dynamic>>> getCategories();
  Future<List<AgendaLock>> getAgendaLocks();
  Future<AgendaLock> createAgendaLock(AgendaLock lock);
  Future<void> deleteAgendaLock(String id);
}

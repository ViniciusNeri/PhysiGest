import 'package:physigest/features/schedule/domain/models/appointment.dart';
import 'package:physigest/features/schedule/domain/models/agenda_lock.dart';

abstract class IScheduleRepository {
  Future<List<Appointment>> getAppointments();
  Future<Appointment> createAppointment(Appointment appointment);
  Future<Appointment> updateAppointment(Appointment appointment);
  Future<void> deleteAppointment(String id);
  Future<List<Map<String, dynamic>>> getAvailablePatients();
  Future<List<Map<String, dynamic>>> getCategories({String? userId});
  Future<List<AgendaLock>> getAgendaLocks();
  Future<AgendaLock> createAgendaLock(AgendaLock lock);
  Future<void> deleteAgendaLock(String id);
  Future<List<DateTime>> getAvailableSlots(String userId, String date);
  Future<void> createOnlineAppointment({
    required String userId,
    required String pin,
    required DateTime startDate,
    required String categoryId,
  });
}

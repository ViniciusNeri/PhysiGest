import 'package:physigest/features/schedule/domain/models/appointment.dart';

abstract class IScheduleRepository {
  Future<List<Appointment>> getAppointments(DateTime from, DateTime to);
  Future<Appointment> createAppointment(Appointment appointment);
  Future<Appointment> updateAppointment(Appointment appointment);
  Future<void> deleteAppointment(String id);
  Future<List<String>> getAvailablePatients();
}

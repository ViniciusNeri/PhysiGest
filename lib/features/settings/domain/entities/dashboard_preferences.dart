import 'package:equatable/equatable.dart';

class DashboardPreferences extends Equatable {
  final bool showDailyAppointments;
  final bool showPendingPayments;
  final bool showWeeklyAppointments;
  final bool showExpiredRecords;

  const DashboardPreferences({
    this.showDailyAppointments = true,
    this.showPendingPayments = true,
    this.showWeeklyAppointments = true,
    this.showExpiredRecords = true,
  });

  DashboardPreferences copyWith({
    bool? showDailyAppointments,
    bool? showPendingPayments,
    bool? showWeeklyAppointments,
    bool? showExpiredRecords,
  }) {
    return DashboardPreferences(
      showDailyAppointments: showDailyAppointments ?? this.showDailyAppointments,
      showPendingPayments: showPendingPayments ?? this.showPendingPayments,
      showWeeklyAppointments: showWeeklyAppointments ?? this.showWeeklyAppointments,
      showExpiredRecords: showExpiredRecords ?? this.showExpiredRecords,
    );
  }

  @override
  List<Object?> get props => [
        showDailyAppointments,
        showPendingPayments,
        showWeeklyAppointments,
        showExpiredRecords,
      ];
}

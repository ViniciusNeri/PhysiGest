import '../entities/dashboard_summary.dart';

abstract class IDashboardRepository {
  Future<DashboardSummary> getSummary();
}

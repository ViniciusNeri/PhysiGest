import 'package:injectable/injectable.dart';
import '../entities/dashboard_summary.dart';
import '../repositories/i_dashboard_repository.dart';

@lazySingleton
class GetDashboardSummaryUseCase {
  final IDashboardRepository repository;

  GetDashboardSummaryUseCase(this.repository);

  Future<DashboardSummary> call() async {
    return await repository.getSummary();
  }
}

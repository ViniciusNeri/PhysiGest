import 'package:injectable/injectable.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/i_dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

@LazySingleton(as: IDashboardRepository)
class DashboardRepositoryImpl implements IDashboardRepository {
  final IDashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<DashboardSummary> getSummary() async {
    return await remoteDataSource.getSummary();
  }
}

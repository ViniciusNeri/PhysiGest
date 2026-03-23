import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:physigest/core/error/failures.dart';
import 'package:physigest/core/network/api_client.dart';

// Este é um exemplo de como você deve construir seus próximos repositórios
// consumindo a API construída nos passos anteriores.

abstract class ExampleRepository {
  Future<Either<Failure, Map<String, dynamic>>> getDashboardData();
}

class ExampleRepositoryImpl implements ExampleRepository {
  final ApiClient _apiClient;

  ExampleRepositoryImpl(this._apiClient);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDashboardData() async {
    try {
      // O ApiClient já possui o Dio configurado e com Interceptors para injetar os Tokens
      final response = await _apiClient.dio.get('/dashboard-summary');

      if (response.statusCode == 200) {
        return Right(response.data);
      } else {
        return const Left(ServerFailure('Ocorreu um erro no servidor.'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Left(UnauthorizedFailure('Sessão expirada.'));
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return const Left(NetworkFailure('Erro de conexão ou timeout.'));
      } else {
        return Left(ServerFailure(e.message ?? 'Erro desconhecido via Dio'));
      }
    } catch (e) {
      // Captura qualquer outro erro e trata como ServerException/Failure pra ser safe
      return Left(ServerFailure(e.toString()));
    }
  }
}

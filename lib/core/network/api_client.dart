import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:physigest/core/network/interceptors/auth_interceptor.dart';
import 'package:physigest/core/network/interceptors/logger_interceptor.dart';

@lazySingleton
class ApiClient {
  late final Dio dio;

  ApiClient({
    required AuthInterceptor authInterceptor,
    required LoggerInterceptor loggerInterceptor,
  }) {
    dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:3000/v1', // Substitua pela URL da sua API
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Adiciona os interceptors
    dio.interceptors.addAll([
      authInterceptor,
      loggerInterceptor,
    ]);
  }
}

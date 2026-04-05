import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:physigest/core/network/interceptors/auth_interceptor.dart';
import 'package:physigest/core/network/interceptors/logger_interceptor.dart';
import 'package:physigest/core/network/interceptors/error_interceptor.dart';

@lazySingleton
class ApiClient {
  late final Dio dio;

  ApiClient({
    required AuthInterceptor authInterceptor,
    required LoggerInterceptor loggerInterceptor,
    required ErrorInterceptor errorInterceptor,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://physiogest-api.onrender.com/v1',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Adiciona os interceptors (ordem importa: ErrorInterceptor por último para capturar falhas processadas)
    dio.interceptors.addAll([authInterceptor, loggerInterceptor, errorInterceptor]);
  }
}

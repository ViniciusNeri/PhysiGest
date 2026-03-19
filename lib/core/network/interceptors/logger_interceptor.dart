import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('==================== HTTP REQUEST ====================', name: 'DIO');
    log('${options.method.toUpperCase()} ${options.uri}', name: 'DIO');
    if (options.data != null) log('Data: ${options.data}', name: 'DIO');
    if (options.queryParameters.isNotEmpty) log('QueryParams: ${options.queryParameters}', name: 'DIO');
    
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('==================== HTTP RESPONSE ====================', name: 'DIO');
    log('${response.statusCode} ${response.requestOptions.uri}', name: 'DIO');
    log('Data: ${response.data}', name: 'DIO');
    
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('==================== HTTP ERROR ====================', name: 'DIO_ERROR');
    log('${err.response?.statusCode} ${err.requestOptions.uri}', name: 'DIO_ERROR');
    log('Error: ${err.message}', name: 'DIO_ERROR');
    if (err.response?.data != null) log('Response Data: ${err.response?.data}', name: 'DIO_ERROR');
    
    return handler.next(err);
  }
}

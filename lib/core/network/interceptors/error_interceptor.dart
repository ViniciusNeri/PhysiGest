import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@injectable
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Tempo de conexão esgotado. Verifique sua internet.';
        break;
      case DioExceptionType.badResponse:
        final data = err.response?.data;
        if (data is Map && data.containsKey('message')) {
          message = data['message'];
        } else {
          message = _mapStatusToMessage(err.response?.statusCode);
        }
        break;
      case DioExceptionType.cancel:
        message = 'A requisição foi cancelada.';
        break;
      case DioExceptionType.connectionError:
        message = 'Sem conexão com o servidor. Verifique sua internet.';
        break;
      default:
        message = 'Ocorreu um erro inesperado. Tente novamente mais tarde.';
        break;
    }

    // Criamos um novo DioException com a mensagem formatada para facilitar o reuso nos DataSources
    final formattedError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: message,
      message: message,
    );

    return handler.next(formattedError);
  }

  String _mapStatusToMessage(int? statusCode) {
    switch (statusCode) {
      case 400: return 'Requisição inválida.';
      case 401: return 'Sessão expirada. Faça login novamente.';
      case 403: return 'Você não tem permissão para realizar esta ação.';
      case 404: return 'Recurso não encontrado.';
      case 500: return 'Erro interno no servidor. Tente novamente mais tarde.';
      default: return 'Erro no servidor ($statusCode).';
    }
  }
}

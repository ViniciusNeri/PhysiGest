import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:physigest/core/storage/local_storage.dart';

@injectable
class AuthInterceptor extends Interceptor {
  final LocalStorage _localStorage;

  AuthInterceptor(this._localStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Busca o token do armazenamento local
    final token = await _localStorage.getToken();

    // Se existir um token, injeta no header
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Trata erro de não autorizado (Token expirado ou inválido)
    if (err.response?.statusCode == 401) {
      // Manda a aplicação deslogar localmente para evitar requests que continuarão falhando
      _localStorage.deleteToken();
      // Opcional: Adicionar lógica para emitir um evento global de "Sessão Expirada"
      // para navegar o usuário de volta para a tela de Login
    }

    return handler.next(err);
  }
}

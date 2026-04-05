import 'package:injectable/injectable.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

@LazySingleton(as: IAuthRepository)
class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<AuthUser> login(String email, String password) async {
    // O Repository liga o request do Datasource à interface de UseCase e retorna O Objeto de Dominio limpo
    return await remoteDataSource.login(email, password);
  }

  @override
  Future<void> forgotPassword(String email) async {
    return await remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> resetPassword(String token, String password) async {
    return await remoteDataSource.resetPassword(token, password);
  }

  @override
  Future<void> logout() async {
    return await remoteDataSource.logout();
  }

  @override
  Future<AuthUser> signUp(String name, String email, String password) async {
    return await remoteDataSource.signUp(name, email, password);
  }

  @override
  Future<AuthUser> confirmSignUp(String email, String confirmationCode) async {
    return await remoteDataSource.confirmSignUp(email, confirmationCode);
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    return await remoteDataSource.signInWithGoogle();
  }

  @override
  Future<AuthUser> signInWithApple() async {
    return await remoteDataSource.signInWithApple();
  }
}

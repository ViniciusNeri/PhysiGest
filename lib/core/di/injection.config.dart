// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/datasources/auth_remote_datasource.dart'
    as _i161;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/i_auth_repository.dart'
    as _i589;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/presentation/bloc/forgot_password/forgot_password_bloc.dart'
    as _i1055;
import '../../features/auth/presentation/bloc/login/login_bloc.dart' as _i208;
import '../../features/auth/presentation/bloc/signup/signup_bloc.dart' as _i173;
import '../../features/auth/presentation/bloc/verify/verify_bloc.dart' as _i6;
import '../../features/dashboard/presentation/bloc/dashboard/dashboard_bloc.dart'
    as _i72;
import '../../features/exercises/presentation/bloc/exercise_bloc.dart' as _i29;
import '../../features/financial/presentation/bloc/financial_bloc.dart'
    as _i911;
import '../../features/patients/presentation/bloc/patient_bloc.dart' as _i1035;
import '../../features/schedule/presentation/bloc/schedule_bloc.dart' as _i1063;
import '../../features/settings/presentation/bloc/settings/settings_bloc.dart'
    as _i228;
import '../network/api_client.dart' as _i557;
import '../network/interceptors/auth_interceptor.dart' as _i745;
import '../network/interceptors/logger_interceptor.dart' as _i238;
import '../storage/local_storage.dart' as _i329;
import '../storage/local_storage_impl.dart' as _i28;
import 'storage_module.dart' as _i371;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final storageModule = _$StorageModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => storageModule.prefs,
      preResolve: true,
    );
    gh.factory<_i238.LoggerInterceptor>(() => _i238.LoggerInterceptor());
    gh.factory<_i72.DashboardBloc>(() => _i72.DashboardBloc());
    gh.factory<_i911.FinancialBloc>(() => _i911.FinancialBloc());
    gh.factory<_i1035.PatientBloc>(() => _i1035.PatientBloc());
    gh.factory<_i1063.ScheduleBloc>(() => _i1063.ScheduleBloc());
    gh.factory<_i228.SettingsBloc>(() => _i228.SettingsBloc());
    gh.lazySingleton<_i29.ExerciseBloc>(() => _i29.ExerciseBloc());
    gh.factory<_i329.LocalStorage>(
      () => _i28.LocalStorageImpl(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i745.AuthInterceptor>(
      () => _i745.AuthInterceptor(gh<_i329.LocalStorage>()),
    );
    gh.lazySingleton<_i557.ApiClient>(
      () => _i557.ApiClient(
        authInterceptor: gh<_i745.AuthInterceptor>(),
        loggerInterceptor: gh<_i238.LoggerInterceptor>(),
      ),
    );
    gh.lazySingleton<_i161.IAuthRemoteDataSource>(
      () => _i161.AuthRemoteDataSource(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i589.IAuthRepository>(
      () => _i153.AuthRepositoryImpl(gh<_i161.IAuthRemoteDataSource>()),
    );
    gh.lazySingleton<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i589.IAuthRepository>()),
    );
    gh.lazySingleton<_i188.ForgotPasswordUseCase>(
      () => _i188.ForgotPasswordUseCase(gh<_i589.IAuthRepository>()),
    );
    gh.lazySingleton<_i188.ResetPasswordUseCase>(
      () => _i188.ResetPasswordUseCase(gh<_i589.IAuthRepository>()),
    );
    gh.lazySingleton<_i188.LogoutUseCase>(
      () => _i188.LogoutUseCase(gh<_i589.IAuthRepository>()),
    );
    gh.lazySingleton<_i188.SignUpUseCase>(
      () => _i188.SignUpUseCase(gh<_i589.IAuthRepository>()),
    );
    gh.lazySingleton<_i188.ConfirmSignUpUseCase>(
      () => _i188.ConfirmSignUpUseCase(gh<_i589.IAuthRepository>()),
    );
    gh.lazySingleton<_i188.SignInWithGoogleUseCase>(
      () => _i188.SignInWithGoogleUseCase(gh<_i589.IAuthRepository>()),
    );
    gh.lazySingleton<_i188.SignInWithAppleUseCase>(
      () => _i188.SignInWithAppleUseCase(gh<_i589.IAuthRepository>()),
    );
    gh.factory<_i6.VerifyBloc>(
      () => _i6.VerifyBloc(gh<_i188.ConfirmSignUpUseCase>()),
    );
    gh.factory<_i1055.ForgotPasswordBloc>(
      () => _i1055.ForgotPasswordBloc(
        gh<_i188.ForgotPasswordUseCase>(),
        gh<_i188.ResetPasswordUseCase>(),
      ),
    );
    gh.factory<_i208.LoginBloc>(
      () => _i208.LoginBloc(gh<_i188.LoginUseCase>()),
    );
    gh.factory<_i173.SignUpBloc>(
      () => _i173.SignUpBloc(gh<_i188.SignUpUseCase>()),
    );
    return this;
  }
}

class _$StorageModule extends _i371.StorageModule {}

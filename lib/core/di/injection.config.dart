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
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart'
    as _i817;
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i509;
import '../../features/dashboard/domain/repositories/i_dashboard_repository.dart'
    as _i485;
import '../../features/dashboard/domain/usecases/dashboard_usecases.dart'
    as _i527;
import '../../features/dashboard/presentation/bloc/dashboard/dashboard_bloc.dart'
    as _i72;
import '../../features/exercises/presentation/bloc/exercise_bloc.dart' as _i29;
import '../../features/financial/data/datasources/financial_remote_datasource.dart'
    as _i599;
import '../../features/financial/data/repositories/financial_repository_impl.dart'
    as _i467;
import '../../features/financial/domain/repositories/i_financial_repository.dart'
    as _i644;
import '../../features/financial/domain/usecases/financial_usecases.dart'
    as _i63;
import '../../features/financial/presentation/bloc/financial_bloc.dart'
    as _i911;
import '../../features/patient_booking/presentation/bloc/patient_booking_bloc.dart'
    as _i570;
import '../../features/patients/data/datasources/patient_remote_datasource.dart'
    as _i286;
import '../../features/patients/data/repositories/patient_repository_impl.dart'
    as _i260;
import '../../features/patients/domain/repositories/i_patient_repository.dart'
    as _i37;
import '../../features/patients/domain/usecases/patient_usecases.dart' as _i160;
import '../../features/patients/presentation/bloc/agenda_bloc.dart' as _i776;
import '../../features/patients/presentation/bloc/anamnesis_bloc.dart' as _i834;
import '../../features/patients/presentation/bloc/patient_activities_bloc.dart'
    as _i460;
import '../../features/patients/presentation/bloc/patient_attachment_bloc.dart'
    as _i821;
import '../../features/patients/presentation/bloc/patient_bloc.dart' as _i1035;
import '../../features/patients/presentation/bloc/patient_financial_bloc.dart'
    as _i220;
import '../../features/schedule/data/datasources/schedule_remote_datasource.dart'
    as _i115;
import '../../features/schedule/data/repositories/schedule_repository_impl.dart'
    as _i688;
import '../../features/schedule/domain/repositories/i_schedule_repository.dart'
    as _i226;
import '../../features/schedule/domain/usecases/schedule_usecases.dart'
    as _i399;
import '../../features/schedule/presentation/bloc/schedule_bloc.dart' as _i1063;
import '../../features/settings/data/datasources/settings_remote_datasource.dart'
    as _i140;
import '../../features/settings/data/repositories/settings_repository_impl.dart'
    as _i955;
import '../../features/settings/domain/repositories/i_settings_repository.dart'
    as _i657;
import '../../features/settings/domain/usecases/settings_usecases.dart'
    as _i279;
import '../../features/settings/presentation/bloc/settings/settings_bloc.dart'
    as _i228;
import '../network/api_client.dart' as _i557;
import '../network/interceptors/auth_interceptor.dart' as _i745;
import '../network/interceptors/error_interceptor.dart' as _i511;
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
    gh.factory<_i511.ErrorInterceptor>(() => _i511.ErrorInterceptor());
    gh.factory<_i238.LoggerInterceptor>(() => _i238.LoggerInterceptor());
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
        errorInterceptor: gh<_i511.ErrorInterceptor>(),
      ),
    );
    gh.lazySingleton<_i140.ISettingsRemoteDataSource>(
      () => _i140.SettingsRemoteDataSource(
        gh<_i557.ApiClient>(),
        gh<_i329.LocalStorage>(),
      ),
    );
    gh.lazySingleton<_i161.IAuthRemoteDataSource>(
      () => _i161.AuthRemoteDataSource(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i599.IFinancialRemoteDataSource>(
      () => _i599.FinancialRemoteDataSource(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i286.IPatientRemoteDataSource>(
      () => _i286.PatientRemoteDataSource(
        gh<_i557.ApiClient>(),
        gh<_i329.LocalStorage>(),
      ),
    );
    gh.lazySingleton<_i817.IDashboardRemoteDataSource>(
      () => _i817.DashboardRemoteDataSource(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i589.IAuthRepository>(
      () => _i153.AuthRepositoryImpl(gh<_i161.IAuthRemoteDataSource>()),
    );
    gh.lazySingleton<_i115.IScheduleRemoteDataSource>(
      () => _i115.ScheduleRemoteDataSource(
        gh<_i557.ApiClient>(),
        gh<_i329.LocalStorage>(),
      ),
    );
    gh.lazySingleton<_i226.IScheduleRepository>(
      () => _i688.ScheduleRepositoryImpl(gh<_i115.IScheduleRemoteDataSource>()),
    );
    gh.factory<_i776.AgendaBloc>(
      () => _i776.AgendaBloc(gh<_i286.IPatientRemoteDataSource>()),
    );
    gh.factory<_i821.PatientAttachmentBloc>(
      () => _i821.PatientAttachmentBloc(gh<_i286.IPatientRemoteDataSource>()),
    );
    gh.lazySingleton<_i657.ISettingsRepository>(
      () => _i955.SettingsRepositoryImpl(gh<_i140.ISettingsRemoteDataSource>()),
    );
    gh.lazySingleton<_i279.GetCategoriesUseCase>(
      () => _i279.GetCategoriesUseCase(gh<_i657.ISettingsRepository>()),
    );
    gh.lazySingleton<_i279.CreateCategoryUseCase>(
      () => _i279.CreateCategoryUseCase(gh<_i657.ISettingsRepository>()),
    );
    gh.lazySingleton<_i279.UpdateCategoryUseCase>(
      () => _i279.UpdateCategoryUseCase(gh<_i657.ISettingsRepository>()),
    );
    gh.lazySingleton<_i279.DeleteCategoryUseCase>(
      () => _i279.DeleteCategoryUseCase(gh<_i657.ISettingsRepository>()),
    );
    gh.lazySingleton<_i279.GetPaymentMethodsUseCase>(
      () => _i279.GetPaymentMethodsUseCase(gh<_i657.ISettingsRepository>()),
    );
    gh.lazySingleton<_i279.CreatePaymentMethodUseCase>(
      () => _i279.CreatePaymentMethodUseCase(gh<_i657.ISettingsRepository>()),
    );
    gh.lazySingleton<_i279.UpdatePaymentMethodUseCase>(
      () => _i279.UpdatePaymentMethodUseCase(gh<_i657.ISettingsRepository>()),
    );
    gh.lazySingleton<_i279.DeletePaymentMethodUseCase>(
      () => _i279.DeletePaymentMethodUseCase(gh<_i657.ISettingsRepository>()),
    );
    gh.lazySingleton<_i279.ChangePasswordUseCase>(
      () => _i279.ChangePasswordUseCase(gh<_i657.ISettingsRepository>()),
    );
    gh.lazySingleton<_i279.GetDashboardPreferencesUseCase>(
      () =>
          _i279.GetDashboardPreferencesUseCase(gh<_i657.ISettingsRepository>()),
    );
    gh.lazySingleton<_i279.UpdateDashboardPreferencesUseCase>(
      () => _i279.UpdateDashboardPreferencesUseCase(
        gh<_i657.ISettingsRepository>(),
      ),
    );
    gh.factory<_i228.SettingsBloc>(
      () => _i228.SettingsBloc(
        gh<_i279.GetCategoriesUseCase>(),
        gh<_i279.GetPaymentMethodsUseCase>(),
        gh<_i279.GetDashboardPreferencesUseCase>(),
        gh<_i279.CreateCategoryUseCase>(),
        gh<_i279.UpdateCategoryUseCase>(),
        gh<_i279.DeleteCategoryUseCase>(),
        gh<_i279.CreatePaymentMethodUseCase>(),
        gh<_i279.UpdatePaymentMethodUseCase>(),
        gh<_i279.DeletePaymentMethodUseCase>(),
        gh<_i279.UpdateDashboardPreferencesUseCase>(),
        gh<_i226.IScheduleRepository>(),
        gh<_i329.LocalStorage>(),
      ),
    );
    gh.lazySingleton<_i644.IFinancialRepository>(
      () =>
          _i467.FinancialRepositoryImpl(gh<_i599.IFinancialRemoteDataSource>()),
    );
    gh.lazySingleton<_i399.GetAppointmentsUseCase>(
      () => _i399.GetAppointmentsUseCase(gh<_i226.IScheduleRepository>()),
    );
    gh.lazySingleton<_i399.CreateAppointmentUseCase>(
      () => _i399.CreateAppointmentUseCase(gh<_i226.IScheduleRepository>()),
    );
    gh.lazySingleton<_i399.UpdateAppointmentUseCase>(
      () => _i399.UpdateAppointmentUseCase(gh<_i226.IScheduleRepository>()),
    );
    gh.lazySingleton<_i399.DeleteAppointmentUseCase>(
      () => _i399.DeleteAppointmentUseCase(gh<_i226.IScheduleRepository>()),
    );
    gh.lazySingleton<_i399.GetAvailablePatientsUseCase>(
      () => _i399.GetAvailablePatientsUseCase(gh<_i226.IScheduleRepository>()),
    );
    gh.lazySingleton<_i399.GetCategoriesUseCase>(
      () => _i399.GetCategoriesUseCase(gh<_i226.IScheduleRepository>()),
    );
    gh.lazySingleton<_i399.GetAgendaLocksUseCase>(
      () => _i399.GetAgendaLocksUseCase(gh<_i226.IScheduleRepository>()),
    );
    gh.lazySingleton<_i399.CreateAgendaLockUseCase>(
      () => _i399.CreateAgendaLockUseCase(gh<_i226.IScheduleRepository>()),
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
    gh.lazySingleton<_i37.IPatientRepository>(
      () => _i260.PatientRepositoryImpl(gh<_i286.IPatientRemoteDataSource>()),
    );
    gh.lazySingleton<_i485.IDashboardRepository>(
      () =>
          _i509.DashboardRepositoryImpl(gh<_i817.IDashboardRemoteDataSource>()),
    );
    gh.factory<_i570.PatientBookingBloc>(
      () => _i570.PatientBookingBloc(gh<_i226.IScheduleRepository>()),
    );
    gh.lazySingleton<_i527.GetDashboardSummaryUseCase>(
      () => _i527.GetDashboardSummaryUseCase(gh<_i485.IDashboardRepository>()),
    );
    gh.lazySingleton<_i160.GetPatientsUseCase>(
      () => _i160.GetPatientsUseCase(gh<_i37.IPatientRepository>()),
    );
    gh.lazySingleton<_i160.GetPatientByIdUseCase>(
      () => _i160.GetPatientByIdUseCase(gh<_i37.IPatientRepository>()),
    );
    gh.lazySingleton<_i160.CreatePatientUseCase>(
      () => _i160.CreatePatientUseCase(gh<_i37.IPatientRepository>()),
    );
    gh.lazySingleton<_i160.UpdatePatientUseCase>(
      () => _i160.UpdatePatientUseCase(gh<_i37.IPatientRepository>()),
    );
    gh.lazySingleton<_i160.DeletePatientUseCase>(
      () => _i160.DeletePatientUseCase(gh<_i37.IPatientRepository>()),
    );
    gh.lazySingleton<_i160.UpdateAnamnesisUseCase>(
      () => _i160.UpdateAnamnesisUseCase(gh<_i37.IPatientRepository>()),
    );
    gh.lazySingleton<_i160.GetLatestAnamnesisUseCase>(
      () => _i160.GetLatestAnamnesisUseCase(gh<_i37.IPatientRepository>()),
    );
    gh.lazySingleton<_i160.CreateAnamnesisUseCase>(
      () => _i160.CreateAnamnesisUseCase(gh<_i37.IPatientRepository>()),
    );
    gh.lazySingleton<_i160.GetFinancialSummaryUseCase>(
      () => _i160.GetFinancialSummaryUseCase(gh<_i37.IPatientRepository>()),
    );
    gh.lazySingleton<_i160.AddFinancialRecordUseCase>(
      () => _i160.AddFinancialRecordUseCase(gh<_i37.IPatientRepository>()),
    );
    gh.lazySingleton<_i160.UpdateFinancialStatusUseCase>(
      () => _i160.UpdateFinancialStatusUseCase(gh<_i37.IPatientRepository>()),
    );
    gh.lazySingleton<_i160.GetPatientActivitiesUseCase>(
      () => _i160.GetPatientActivitiesUseCase(gh<_i37.IPatientRepository>()),
    );
    gh.factory<_i6.VerifyBloc>(
      () => _i6.VerifyBloc(gh<_i188.ConfirmSignUpUseCase>()),
    );
    gh.factory<_i1063.ScheduleBloc>(
      () => _i1063.ScheduleBloc(
        gh<_i399.GetAppointmentsUseCase>(),
        gh<_i399.CreateAppointmentUseCase>(),
        gh<_i399.UpdateAppointmentUseCase>(),
        gh<_i399.GetAvailablePatientsUseCase>(),
        gh<_i399.GetCategoriesUseCase>(),
        gh<_i399.DeleteAppointmentUseCase>(),
        gh<_i399.GetAgendaLocksUseCase>(),
        gh<_i399.CreateAgendaLockUseCase>(),
      ),
    );
    gh.factory<_i72.DashboardBloc>(
      () => _i72.DashboardBloc(
        gh<_i527.GetDashboardSummaryUseCase>(),
        gh<_i399.UpdateAppointmentUseCase>(),
      ),
    );
    gh.factory<_i1055.ForgotPasswordBloc>(
      () => _i1055.ForgotPasswordBloc(
        gh<_i188.ForgotPasswordUseCase>(),
        gh<_i188.ResetPasswordUseCase>(),
      ),
    );
    gh.lazySingleton<_i63.GetConsolidatedFinancialDataUseCase>(
      () => _i63.GetConsolidatedFinancialDataUseCase(
        gh<_i644.IFinancialRepository>(),
      ),
    );
    gh.lazySingleton<_i63.CreateTransactionUseCase>(
      () => _i63.CreateTransactionUseCase(gh<_i644.IFinancialRepository>()),
    );
    gh.lazySingleton<_i63.DeleteTransactionUseCase>(
      () => _i63.DeleteTransactionUseCase(gh<_i644.IFinancialRepository>()),
    );
    gh.factory<_i208.LoginBloc>(
      () => _i208.LoginBloc(gh<_i188.LoginUseCase>()),
    );
    gh.factory<_i173.SignUpBloc>(
      () => _i173.SignUpBloc(gh<_i188.SignUpUseCase>()),
    );
    gh.factory<_i834.AnamnesisBloc>(
      () => _i834.AnamnesisBloc(
        gh<_i160.GetLatestAnamnesisUseCase>(),
        gh<_i160.CreateAnamnesisUseCase>(),
        gh<_i160.UpdateAnamnesisUseCase>(),
      ),
    );
    gh.factory<_i460.PatientActivitiesBloc>(
      () =>
          _i460.PatientActivitiesBloc(gh<_i160.GetPatientActivitiesUseCase>()),
    );
    gh.factory<_i220.PatientFinancialBloc>(
      () => _i220.PatientFinancialBloc(
        gh<_i160.GetFinancialSummaryUseCase>(),
        gh<_i160.AddFinancialRecordUseCase>(),
        gh<_i160.UpdateFinancialStatusUseCase>(),
      ),
    );
    gh.factory<_i1035.PatientBloc>(
      () => _i1035.PatientBloc(
        gh<_i160.GetPatientsUseCase>(),
        gh<_i160.CreatePatientUseCase>(),
        gh<_i160.UpdatePatientUseCase>(),
        gh<_i160.DeletePatientUseCase>(),
      ),
    );
    gh.factory<_i911.FinancialBloc>(
      () => _i911.FinancialBloc(
        gh<_i63.GetConsolidatedFinancialDataUseCase>(),
        gh<_i63.CreateTransactionUseCase>(),
        gh<_i63.DeleteTransactionUseCase>(),
        gh<_i329.LocalStorage>(),
      ),
    );
    return this;
  }
}

class _$StorageModule extends _i371.StorageModule {}

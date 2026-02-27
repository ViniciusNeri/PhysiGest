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

import '../../features/auth/presentation/bloc/forgot_password/forgot_password_bloc.dart'
    as _i1055;
import '../../features/auth/presentation/bloc/login/login_bloc.dart' as _i208;
import '../../features/auth/presentation/bloc/signup/signup_bloc.dart' as _i173;
import '../../features/dashboard/presentation/bloc/dashboard/dashboard_bloc.dart'
    as _i72;
import '../../features/patients/presentation/bloc/patient_bloc.dart' as _i1035;
import '../../features/schedule/presentation/bloc/schedule_bloc.dart' as _i1063;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i1055.ForgotPasswordBloc>(() => _i1055.ForgotPasswordBloc());
    gh.factory<_i208.LoginBloc>(() => _i208.LoginBloc());
    gh.factory<_i173.SignUpBloc>(() => _i173.SignUpBloc());
    gh.factory<_i72.DashboardBloc>(() => _i72.DashboardBloc());
    gh.factory<_i1035.PatientBloc>(() => _i1035.PatientBloc());
    gh.factory<_i1063.ScheduleBloc>(() => _i1063.ScheduleBloc());
    return this;
  }
}

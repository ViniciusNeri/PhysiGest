import 'package:go_router/go_router.dart';
import 'package:physigest/features/auth/presentation/screens/login_screen.dart';
import 'package:physigest/features/auth/presentation/screens/signup_screen.dart';
import 'package:physigest/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:physigest/features/dashboard/presentation/screens/home_screen.dart';
import 'package:physigest/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:physigest/features/patients/presentation/screens/patients_list_screen.dart';
import 'package:physigest/features/patients/presentation/screens/edit_patient_screen.dart';
import 'package:physigest/features/patients/presentation/screens/patient_profile_screen.dart';
import 'package:physigest/features/financial/presentation/screens/financial_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: '/patients',
        builder: (context, state) => const PatientsListScreen(),
      ),
      GoRoute(
        path: '/financial',
        builder: (context, state) => const FinancialScreen(),
      ),
      GoRoute(
        path: '/patients/new',
        builder: (context, state) => const EditPatientScreen(),
      ),
      GoRoute(
        path: '/patients/:id',
        builder: (context, state) {
          final patient = state.extra; // Patient passed via extra
          return PatientProfileScreen(patient: patient as dynamic);
        },
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}


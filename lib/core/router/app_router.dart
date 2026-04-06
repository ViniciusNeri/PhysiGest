import 'package:go_router/go_router.dart';
import 'package:physigest/features/auth/presentation/screens/login_screen.dart';
import 'package:physigest/features/auth/presentation/screens/signup_screen.dart';
import 'package:physigest/features/auth/presentation/screens/verify_screen.dart';
import 'package:physigest/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:physigest/features/dashboard/presentation/screens/home_screen.dart';
import 'package:physigest/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:physigest/features/patients/presentation/screens/patients_list_screen.dart';
import 'package:physigest/features/patients/presentation/screens/patient_profile_screen.dart';
import 'package:physigest/features/financial/presentation/screens/financial_screen.dart';
import 'package:physigest/features/exercises/presentation/screens/exercises_list_screen.dart';
import 'package:physigest/features/settings/presentation/screens/settings_screen.dart';
import 'package:physigest/features/settings/presentation/screens/categories_settings_screen.dart';
import 'package:physigest/features/settings/presentation/screens/payment_methods_settings_screen.dart';
import 'package:physigest/features/auth/presentation/screens/new_password_screen.dart';
import 'package:physigest/features/patient_booking/presentation/screens/patient_booking_screen.dart';
import 'package:physigest/core/storage/local_storage.dart';
import 'package:physigest/core/di/injection.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final publicRoutes = [
        '/login',
        '/signup',
        '/forgot-password',
        '/reset-password',
        '/verify',
        '/agendar',
      ];

      final localStorage = getIt<LocalStorage>();
      final String? token = localStorage.getTokenSync();
      final bool loggedIn = token != null && token.isNotEmpty;
      final isGoingToPublic = publicRoutes.contains(state.matchedLocation);

      if (!loggedIn && !isGoingToPublic) {
        return '/login';
      }

      if (loggedIn && state.matchedLocation == '/login') {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/verify',
        builder: (context, state) {
          final email = state.extra as String;
          return VerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return NewPasswordScreen(token: token);
        },
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: '/agendar',
        builder: (context, state) {
          final userId = state.uri.queryParameters['userId'] ?? '';
          return PatientBookingScreen(userId: userId);
        },
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
        path: '/exercises',
        builder: (context, state) => const ExercisesListScreen(),
      ),
      GoRoute(
        path: '/patients/:id',
        builder: (context, state) {
          final patient = state.extra; // Patient passed via extra
          return PatientProfileScreen(patient: patient as dynamic);
        },
      ),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'categories',
            builder: (context, state) => const CategoriesSettingsScreen(),
          ),
          GoRoute(
            path: 'payments',
            builder: (context, state) => const PaymentMethodsSettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

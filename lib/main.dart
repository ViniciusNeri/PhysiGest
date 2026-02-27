import 'package:flutter/material.dart';
import 'package:physigest/core/di/injection.dart';
import 'package:physigest/core/router/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:physigest/core/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  configureDependencies();
  runApp(const PhysiGestApp());
}

class PhysiGestApp extends StatelessWidget {
  const PhysiGestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PhysiGest',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
    );
  }
}

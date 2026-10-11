import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'state/app_state.dart';
import 'features/splash/splash_screen.dart';

class AutoCareApp extends StatefulWidget {
  const AutoCareApp({super.key});

  @override
  State<AutoCareApp> createState() => _AutoCareAppState();
}

class _AutoCareAppState extends State<AutoCareApp> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

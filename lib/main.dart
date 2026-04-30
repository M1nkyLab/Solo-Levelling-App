import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force OLED-friendly status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const SoloLevellingApp());
}

class SoloLevellingApp extends StatelessWidget {
  const SoloLevellingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shadow Levelling',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.shadowMonarch,
      home: const DashboardScreen(),
    );
  }
}



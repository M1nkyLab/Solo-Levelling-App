import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // ── PERF: Warm up shaders and cache before first frame
  // This reduces the 'first-scroll jank' by pre-preparing the raster cache.
  await binding.defaultBinaryMessenger.send('flutter/service', null);
  SchedulerBinding.instance.addPostFrameCallback((_) {
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50MB
  });

  // Initialize Supabase
  // Replace these with your actual Supabase project credentials
  await Supabase.initialize(
    url: 'https://YOUR_PROJECT_ID.supabase.co',
    anonKey: 'YOUR_ANON_KEY',
  );

  // Force OLED-friendly status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: SoloLevellingApp(),
    ),
  );
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



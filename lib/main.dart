import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/quests/dashboard_screen.dart';
import 'package:solo_levelling_app/features/auth/login_screen.dart';
import 'package:solo_levelling_app/features/auth/auth_provider.dart';
import 'package:solo_levelling_app/features/quests/schedule_provider.dart';
import 'package:solo_levelling_app/features/quests/schedule_selection_screen.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // ── PERF: Warm up shaders and cache before first frame
  await binding.defaultBinaryMessenger.send('flutter/service', null);
  SchedulerBinding.instance.addPostFrameCallback((_) {
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50MB
  });

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

class SoloLevellingApp extends ConsumerWidget {
  const SoloLevellingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final scheduleState = ref.watch(scheduleProvider);

    Widget home;
    if (authState.isLoading) {
      home = const SplashScreen();
    } else if (authState.isAuthenticated) {
      if (scheduleState.isConfigured) {
        home = const DashboardScreen();
      } else {
        home = const ScheduleSelectionScreen();
      }
    } else {
      home = const LoginScreen();
    }

    return MaterialApp(
      title: 'Shadow Levelling',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.shadowMonarch,
      home: home,
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'INITIALIZING SYSTEM...',
              style: ShadowTextTheme.mono(12, color: ShadowColors.amethystLight),
            ),
          ],
        ),
      ),
    );
  }
}



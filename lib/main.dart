import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/quests/dashboard_screen.dart';
import 'package:solo_levelling_app/features/auth/login_screen.dart';
import 'package:solo_levelling_app/features/auth/auth_provider.dart';
import 'package:solo_levelling_app/features/quests/schedule_provider.dart';
import 'package:solo_levelling_app/features/quests/schedule_selection_screen.dart';
import 'package:solo_levelling_app/features/player/player_provider.dart';
import 'package:solo_levelling_app/features/quests/quest_provider.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // ── SUPABASE: Initialize connection
  await Supabase.initialize(
    url: 'https://hrnkfckmvzplmnndmncn.supabase.co',
    anonKey: 'sb_publishable_5qNpHH_QKfxgyiVX3_uuXA_774SJ2ny',
  );

  // ── PERF: Warm up shaders and cache
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

    // ── SYSTEM: Handle per-user schedule and quest loading
    ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated && next.user != null) {
        // Run sequence in a closure to ensure proper initialization order
        () async {
          // 1. Ensure player exists and is synced first
          await ref.read(playerProvider.notifier).fetchFromSupabase();
          // 2. Load schedule and quests now that we know player record exists
          await ref.read(scheduleProvider.notifier).loadForUser(next.user!.id);
          final schedule = ref.read(scheduleProvider);
          await ref.read(questProvider.notifier).fetchQuests(next.user!.id, localSchedule: schedule.days);
        }();
      } else if (!next.isAuthenticated) {
        ref.read(scheduleProvider.notifier).reset();
        ref.read(playerProvider.notifier).reset();
      }
    });

    Widget home;
    if (authState.isLoading || (authState.isAuthenticated && scheduleState.isLoading)) {
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
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.deepPurpleAccent),
            const SizedBox(height: 24),
            Text(
              'INITIALIZING SYSTEM...',
              style: TextStyle(
                color: Colors.deepPurple[100],
                fontFamily: 'monospace',
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

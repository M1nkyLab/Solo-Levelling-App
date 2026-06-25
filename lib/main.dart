
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/main/main_screen.dart';
import 'package:solo_levelling_app/features/auth/login_screen.dart';
import 'package:solo_levelling_app/features/auth/auth_provider.dart';
import 'package:solo_levelling_app/features/quests/schedule_provider.dart';
import 'package:solo_levelling_app/features/quests/schedule_selection_screen.dart';
import 'package:solo_levelling_app/features/player/player_provider.dart';
import 'package:solo_levelling_app/features/quests/quest_provider.dart';
import 'package:solo_levelling_app/core/logic/sync_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:solo_levelling_app/core/models/workout_state.dart';
import 'package:solo_levelling_app/features/quests/daily_quest.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();

  // ── SUPABASE: Initialize connection
  // TODO: Replace with your actual Supabase URL and Anon Key via --dart-define or .env
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL', defaultValue: 'YOUR_SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'YOUR_SUPABASE_ANON_KEY'),
  );

  // ── HIVE: Initialize local storage
  await Hive.initFlutter();
  Hive.registerAdapter(WorkoutStateAdapter());
  Hive.registerAdapter(DailyQuestAdapter());
  await Hive.openBox<DailyQuest>('questsBox');

  // ── PERF: Warm up shaders and cache
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
    // Initialize services
    ref.watch(syncServiceProvider);

    final authState = ref.watch(authProvider);
    final isScheduleLoaded =
        ref.watch(scheduleProvider.select((s) => s.isLoaded));
    final isPlayerLoaded = ref.watch(playerProvider.select((p) => p.isLoaded));

    Future<void> loadUserData(String userId) async {
      // 1. Ensure player exists and is synced first
      await ref.read(playerProvider.notifier).fetchFromSupabase();
      // 2. Load schedule and quests now that we know player record exists
      await ref.read(scheduleProvider.notifier).loadForUser(userId);
      final schedule = ref.read(scheduleProvider);
      await ref
          .read(questProvider.notifier)
          .fetchQuests(userId, localSchedule: schedule.days);
    }

    // ── SYSTEM: Handle per-user schedule and quest loading
    ref.listen(authProvider, (previous, next) {
      final wasAuthenticated = previous?.isAuthenticated ?? false;
      if (!wasAuthenticated && next.isAuthenticated && next.user != null) {
        loadUserData(next.user!.id);
      } else if (wasAuthenticated && !next.isAuthenticated) {
        ref.read(scheduleProvider.notifier).reset();
        ref.read(playerProvider.notifier).reset();
      }
    });

    final bool isScheduleLoading =
        ref.watch(scheduleProvider.select((s) => s.isLoading));

    // ── SYSTEM: Trigger data load if already authenticated on startup
    if (authState.isAuthenticated &&
        authState.user != null &&
        !isPlayerLoaded &&
        !isScheduleLoaded &&
        !isScheduleLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        loadUserData(authState.user!.id);
      });
    }

    Widget home;
    // ── SYSTEM: Improved transition logic using isLoaded flags
    final bool isAuthenticating = authState.isLoading;
    final bool isSyncingData =
        authState.isAuthenticated && (!isPlayerLoaded || !isScheduleLoaded);

    if (isAuthenticating || isSyncingData) {
      home = const SplashScreen();
    } else if (authState.isAuthenticated) {
      if (!authState.needsScheduleSetup) {
        home = const MainScreen();
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
            const Text(
              'INITIALIZING SYSTEM...',
              style: TextStyle(
                color: Color(0xFFD1C4E9), // Colors.deepPurple[100] equivalent

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

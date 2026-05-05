import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/auth/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter credentials')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).login(username, password);

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('INVALID CREDENTIALS. SYSTEM ACCESS DENIED.'),
          backgroundColor: ShadowColors.hpRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ShadowColors.voidDark,
              ShadowColors.obsidian,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // System Icon / Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ShadowColors.amethyst.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      size: 60,
                      color: ShadowColors.amethyst,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'THE SYSTEM',
                    style: ShadowTextTheme.headline(28, weight: FontWeight.w900).copyWith(
                      letterSpacing: 4,
                      color: ShadowColors.amethystLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AUTHENTICATION REQUIRED',
                    style: ShadowTextTheme.mono(12, color: ShadowColors.textSecondary),
                  ),
                  const SizedBox(height: 48),

                  // Username Input
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'PLAYER NAME',
                      prefixIcon: Icon(Icons.person_outline),
                      hintText: 'Enter "JinWoo" to test',
                    ),
                    style: ShadowTextTheme.mono(14),
                  ),
                  const SizedBox(height: 20),

                  // Password Input
                  TextField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: 'ACCESS CODE',
                      prefixIcon: const Icon(Icons.lock_outline),
                      hintText: 'Enter "level_up" to test',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility : Icons.visibility_off,
                          color: ShadowColors.textSecondary,
                        ),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                    style: ShadowTextTheme.mono(14),
                  ),
                  const SizedBox(height: 40),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _handleLogin,
                      child: authState.isLoading
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : const Text('INITIALIZE ACCESS'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Hint for User
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ShadowColors.surfaceAlt.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ShadowColors.amethyst.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'SYSTEM HINT:',
                          style: ShadowTextTheme.mono(10, color: ShadowColors.amethystLight),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'U: JinWoo | P: level_up',
                          style: ShadowTextTheme.mono(12, color: ShadowColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

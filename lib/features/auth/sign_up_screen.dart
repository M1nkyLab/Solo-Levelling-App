import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/auth/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PLEASE FILL ALL DATA FIELDS.')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).signUp(email, password, username);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('REGISTRATION SUCCESSFUL. CHECK EMAIL IF REQUIRED.'),
          backgroundColor: ShadowColors.amethyst,
        ),
      );
      Navigator.of(context).pop();
    } else {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'REGISTRATION FAILED.'),
          backgroundColor: ShadowColors.hpRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ShadowColors.amethystLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
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
                  const SizedBox(height: 32),

                  Text(
                    'Hunter registration',
                    style: ShadowTextTheme.headline(24, weight: FontWeight.w900).copyWith(
                      letterSpacing: 2,
                      color: ShadowColors.amethystLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Initializing system awakening...',
                    style: ShadowTextTheme.mono(10, color: ShadowColors.textSecondary),
                  ),
                  const SizedBox(height: 48),

                  // Username Input
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Hunter alias',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    style: ShadowTextTheme.mono(14),
                  ),
                  const SizedBox(height: 20),

                  // Email Input
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    style: ShadowTextTheme.mono(14),
                  ),
                  const SizedBox(height: 20),

                  // Password Input
                  TextField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
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

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _handleSignUp,
                      child: authState.isLoading
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : const Text('Arise'),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo_levelling_app/core/theme/app_theme.dart';
import 'package:solo_levelling_app/features/auth/auth_provider.dart';
import 'package:solo_levelling_app/features/auth/sign_up_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter credentials')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).login(email, password);

    if (!mounted) return;

    if (!success) {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'INVALID CREDENTIALS. SYSTEM ACCESS DENIED.'),
          backgroundColor: ShadowColors.hpRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: ShadowColors.obsidian,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),

                // Title Section
                Text(
                  'SYSTEM ACCESS',
                  style: ShadowTextTheme.headline(28, letterSpacing: 3, color: ShadowColors.amethystLight),
                ),
                const SizedBox(height: 12),
                Text(
                  'AUTHENTICATION REQUIRED',
                  style: ShadowTextTheme.mono(10, color: ShadowColors.textSecondary, weight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 48),

                // Rigid Login Panel
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: ShadowColors.surface,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: ShadowColors.systemBorder, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Email Input
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'HUNTER EMAIL',
                          prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                        ),
                        style: ShadowTextTheme.mono(14),
                      ),
                      const SizedBox(height: 20),

                      // Password Input
                      TextField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          labelText: 'ACCESS KEY',
                          prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword ? Icons.visibility : Icons.visibility_off,
                              color: ShadowColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _showPassword = !_showPassword),
                          ),
                        ),
                        style: ShadowTextTheme.mono(14),
                      ),
                      const SizedBox(height: 32),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ShadowColors.amethyst,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                          ),
                          child: authState.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  'ENTER SYSTEM',
                                  style: ShadowTextTheme.mono(14, weight: FontWeight.bold, letterSpacing: 2),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Sign Up Link
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: Text(
                    'NEW HUNTER? INITIATE AWAKENING',
                    style: ShadowTextTheme.mono(11, color: ShadowColors.amethystLight, weight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

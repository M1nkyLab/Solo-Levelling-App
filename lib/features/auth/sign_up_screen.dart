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
      backgroundColor: ShadowColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ShadowColors.amethystLight, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                Text(
                  'HUNTER REGISTRATION',
                  style: ShadowTextTheme.headline(26, letterSpacing: 2, color: ShadowColors.amethystLight),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'INITIALIZING SYSTEM AWAKENING...',
                  style: ShadowTextTheme.mono(10, color: ShadowColors.textSecondary, weight: FontWeight.bold, letterSpacing: 1.5),
                ),
                const SizedBox(height: 40),

                // Rigid Awakening Panel
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
                      // Username Input
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'HUNTER ALIAS',
                          prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                        ),
                        style: ShadowTextTheme.mono(14),
                      ),
                      const SizedBox(height: 20),

                      // Email Input
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'VERIFICATION EMAIL',
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
                          labelText: 'SECURITY KEY',
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

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _handleSignUp,
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
                                  'ARISE',
                                  style: ShadowTextTheme.mono(16, weight: FontWeight.bold, letterSpacing: 8),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

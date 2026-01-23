import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../provider/auth_provider.dart';
import '../../../../main.dart'; // Circular dep for now, normally navigation logic is separate
import 'package:more_experts/core/widgets/app_loader.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo or Header
                    Image.asset('assets/images/logo2.png',
                            width: 120, height: 120)
                        .animate()
                        .fade()
                        .scale(duration: 600.ms),

                    const SizedBox(height: 32),

                    Text(
                      'MoRe Experts',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                    ).animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0),

                    Text(
                      'Client Portal',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.mediaGray,
                          ),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 64),

                    // Inputs
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 400.ms).moveX(begin: -10, end: 0),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.mediaGray,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter your password'
                          : null,
                    ).animate().fadeIn(delay: 500.ms).moveX(begin: 10, end: 0),

                    const SizedBox(height: 32),

                    // Login Button
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return ElevatedButton(
                          onPressed: auth.status == AuthStatus.loading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    await auth.login(
                                        _emailController.text.trim(),
                                        _passwordController.text);
                                    // Navigation logic would go here typically
                                  }
                                },
                          child: auth.status == AuthStatus.loading
                              ? const AppLoader(
                                  size: 20,
                                  color: AppColors.white,
                                )
                              : const Text('Login'),
                        );
                      },
                    ).animate().fadeIn(delay: 600.ms).moveY(begin: 20, end: 0),

                    // Error Message
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        if (auth.errorMessage != null) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              auth.errorMessage!,
                              style: const TextStyle(color: AppColors.error),
                              textAlign: TextAlign.center,
                            ),
                          ).animate().fadeIn();
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'Contact Admin via WhatsApp if you lost your credentials.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mediaGray,
                          ),
                    ).animate().fadeIn(delay: 800.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

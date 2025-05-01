import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotter_app/bloc/auth/auth_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/start');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message)
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    // Logo ili naslov
                    Text(
                      'SPOTTER',
                        style: GoogleFonts.poppins(
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                          color:  Theme.of(context).colorScheme.primary,
                          //letterSpacing: 2,
                        )
                    ),
                    const SizedBox(height: 40),
                    // Polje za e-mail
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        prefixIcon:
                            const Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Polje za lozinku
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        prefixIcon:
                            const Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Polje za username
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        hintText: 'Username (for sign up)',
                        prefixIcon:
                            const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Gumb za Sign In
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              SignInWithEmail(
                                email: emailController.text,
                                password: passwordController.text,
                              ),
                            );
                      },
                      child: const Text('Sign In'),
                    ),
                    const SizedBox(height: 16),
                    // Gumb za Sign Up
                   ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              SignUpWithEmail(
                                email: emailController.text,
                                password: passwordController.text,
                                username: usernameController.text,
                              ),
                            );
                      },
                     child: const Text('Sign up'),
                    ),
                    const SizedBox(height: 16),
                    // Gumb za Google Sign-In
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<AuthBloc>().add(SignInWithGoogle());
                      },
                      icon: const Icon(Icons.g_mobiledata),
                      label: const Text('Sign In with Google'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gyanvruksh/services/api.dart';
import 'package:gyanvruksh/screens/role_selection.dart';
import 'package:gyanvruksh/screens/navigation.dart';
import 'package:gyanvruksh/widgets/custom_animated_button.dart';
import 'package:gyanvruksh/widgets/custom_form_field.dart';
import 'package:gyanvruksh/widgets/glassmorphism_card.dart';
import 'package:gyanvruksh/widgets/neumorphism_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  String? error;
  late AnimationController _backgroundController;
  late Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = ColorTween(
      begin: const Color(0xFF3C6EFA),
      end: const Color(0xFFA58DF5),
    ).animate(_backgroundController);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    // More permissive email regex that allows longer TLDs
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _login() async {
    final emailError = _validateEmail(emailCtrl.text);
    final passwordError = _validatePassword(passCtrl.text);

    if (emailError != null || passwordError != null) {
      setState(() {
        error = emailError ?? passwordError;
      });
      return;
    }

    final cleanEmail = emailCtrl.text.trim();
    final cleanPassword = passCtrl.text.trim();

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final ok = await ApiService().login(cleanEmail, cleanPassword);

      if (!mounted) return;

      if (ok) {
        final me = ApiService().me();
        if (me != null) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  NavigationScreen(user: me),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOutCubic;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
        } else {
          setState(() => error = "Failed to fetch user data");
        }
      } else {
        setState(() => error = "Invalid credentials");
      }
    } catch (e) {
      setState(() => error = "Login error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _backgroundAnimation.value ?? colorScheme.primary,
                  colorScheme.secondary,
                  colorScheme.tertiary,
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  children: [
                    // Header Section
                    SizedBox(
                      height: size.height * 0.3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo with Hero animation
                          Hero(
                            tag: 'app_logo',
                            child: NeumorphismContainer(
                              width: 100,
                              height: 100,
                              borderRadius: BorderRadius.circular(50),
                              child: Icon(
                                FontAwesomeIcons.graduationCap,
                                size: 50,
                                color: colorScheme.primary,
                              ),
                            ),
                          )
                              .animate()
                              .scale(duration: 600.ms, curve: Curves.elasticOut)
                              .fadeIn(duration: 400.ms),

                          const SizedBox(height: 24),

                          Text(
                            'Gyanvruksh',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 200.ms)
                              .slideY(begin: 0.3, end: 0, duration: 500.ms),

                          const SizedBox(height: 8),

                          Text(
                            'Empowering Education',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onPrimary.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 400.ms)
                              .slideY(begin: 0.3, end: 0, duration: 500.ms),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Login Form Card
                    GlassmorphismCard(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      blurStrength: 15,
                      opacity: 0.15,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 600.ms),

                          const SizedBox(height: 8),

                          Text(
                            'Sign in to continue your learning journey',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 700.ms),

                          const SizedBox(height: 32),

                          // Email Field
                          CustomFormField(
                            controller: emailCtrl,
                            labelText: 'Email Address',
                            hintText: 'Enter your email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 800.ms)
                              .slideX(begin: -0.2, end: 0, duration: 400.ms),

                          const SizedBox(height: 20),

                          // Password Field
                          CustomFormField(
                            controller: passCtrl,
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: true,
                            validator: _validatePassword,
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 900.ms)
                              .slideX(begin: 0.2, end: 0, duration: 400.ms),

                          const SizedBox(height: 12),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Forgot password feature coming soon!'),
                                    backgroundColor: colorScheme.secondary,
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 1000.ms),

                          const SizedBox(height: 24),

                          // Error Message
                          if (error != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      error!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .shake(duration: 500.ms),

                          const SizedBox(height: 24),

                          // Login Button
                          CustomAnimatedButton(
                            text: 'Sign In',
                            onPressed: _login,
                            isLoading: loading,
                            height: 56,
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 1100.ms)
                              .slideY(begin: 0.2, end: 0, duration: 400.ms),

                          const SizedBox(height: 24),

                          // Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: colorScheme.outline.withOpacity(0.3))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: colorScheme.onSurface.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: colorScheme.outline.withOpacity(0.3))),
                            ],
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 1200.ms),

                          const SizedBox(height: 24),

                          // Create Account Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                      const RoleSelectionScreen(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    const begin = Offset(0.0, 1.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOutCubic;
                                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                    var offsetAnimation = animation.drive(tween);
                                    return SlideTransition(position: offsetAnimation, child: child);
                                  },
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: colorScheme.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Create New Account',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 1300.ms)
                              .slideY(begin: 0.2, end: 0, duration: 400.ms),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 500.ms)
                        .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
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

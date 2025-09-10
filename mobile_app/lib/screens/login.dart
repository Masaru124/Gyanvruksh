import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gyanvruksh/viewmodels/login_viewmodel.dart';
import 'package:gyanvruksh/screens/role_selection.dart';
import 'package:gyanvruksh/screens/navigation.dart';
import 'package:gyanvruksh/widgets/holographic_button.dart';
import 'package:gyanvruksh/widgets/animated_morphing_form.dart';
import 'package:gyanvruksh/widgets/animated_text_widget.dart';
import 'package:gyanvruksh/widgets/theme_switch_widget.dart';
import 'package:gyanvruksh/widgets/backgrounds/cinematic_background.dart';
import 'package:gyanvruksh/widgets/particle_background.dart';
import 'package:gyanvruksh/widgets/floating_elements.dart';
import 'package:gyanvruksh/theme/futuristic_theme.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late LoginViewModel _viewModel;
  bool _isDark = false;
  late AnimationController _backgroundController;
  late Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel();
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
    _viewModel.dispose();
    super.dispose();
  }

  void _login() async {
    final success = await _viewModel.login();
    if (!mounted) return;

    if (success) {
      final me = _viewModel.apiService.me();
      if (me != null) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                NavigationScreen(user: me),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;
              var tween = Tween(begin: begin, end: end)
                  .chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        );
      } else {
        _viewModel.clearError();
        // Error will be handled by viewmodel
      }
    } else {
      // Error will be handled by viewmodel
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return ChangeNotifierProvider<LoginViewModel>.value(
      value: _viewModel,
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Stack(
              children: [
                // Cinematic Background
                CinematicBackground(isDark: _isDark),

                // Enhanced Particle Background
                ParticleBackground(
                  particleCount: 30,
                  maxParticleSize: 4.0,
                  particleColor: FuturisticColors.primary,
                ),

                // Floating Elements
                FloatingElements(
                  elementCount: 8,
                  maxElementSize: 60,
                  icons: const [
                    Icons.email,
                    Icons.lock,
                    Icons.school,
                    Icons.person,
                    Icons.star,
                    Icons.lightbulb,
                    Icons.computer,
                    Icons.book,
                  ],
                ),

                // Main Content
                SafeArea(
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
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        FuturisticColors.primary,
                                        FuturisticColors.secondary,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            FuturisticColors.primary.withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    FontAwesomeIcons.graduationCap,
                                    size: 60,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              )
                                  .animate()
                                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                                  .fadeIn(duration: 400.ms),

                              const SizedBox(height: 24),

                              // Animated Text Widget
                              AnimatedTextWidget(
                                text: 'Gyanvruksh',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                  shadows: [
                                    Shadow(
                                      color:
                                          FuturisticColors.primary.withOpacity(0.5),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                animationType: AnimationType.typewriter,
                                duration: const Duration(milliseconds: 2000),
                              ),

                              const SizedBox(height: 8),

                              AnimatedTextWidget(
                                text: 'Empowering Education',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                                animationType: AnimationType.fade,
                                duration: const Duration(milliseconds: 1500),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Login Form Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.8),
                                Colors.white.withOpacity(0.6),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Removed animation from Welcome Back text to make it static
                              Text(
                                'Welcome Back',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Removed animation from sign-in instruction text to make it static
                              Text(
                                'Sign in to continue your learning journey',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Email Field with Animated Morphing Form
                              AnimatedMorphingForm(
                                controller: viewModel.emailController,
                                label: 'Email Address',
                                hint: 'Enter your email',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: viewModel.validateEmail,
                              )
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 800.ms)
                                  .slideX(begin: -0.2, end: 0, duration: 400.ms),

                              const SizedBox(height: 20),

                              // Password Field with Animated Morphing Form
                              AnimatedMorphingForm(
                                controller: viewModel.passwordController,
                                label: 'Password',
                                hint: 'Enter your password',
                                prefixIcon: Icons.lock_outline,
                                obscureText: !viewModel.isPasswordVisible,
                                validator: viewModel.validatePassword,
                              )
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 900.ms)
                                  .slideX(begin: 0.2, end: 0, duration: 400.ms),

                              // Password visibility toggle
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Icon(
                                    viewModel.isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  onPressed: viewModel.togglePasswordVisibility,
                                ),
                              ).animate().fadeIn(duration: 400.ms, delay: 950.ms),

                              const SizedBox(height: 12),

                              // Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            'Forgot password feature coming soon!'),
                                        backgroundColor: FuturisticColors.secondary,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: FuturisticColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(duration: 400.ms, delay: 1000.ms),

                              const SizedBox(height: 24),

                              // Error Message
                              if (viewModel.error != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.red.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: Colors.red, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          viewModel.error!,
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
                              HolographicButton(
                                text: 'Sign In',
                                onPressed: _login,
                                isLoading: viewModel.isLoading,
                                height: 56,
                              )
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 1100.ms)
                                  .slideY(begin: 0.2, end: 0, duration: 400.ms),

                              const SizedBox(height: 24),

                              // Divider
                              Row(
                                children: [
                                  Expanded(
                                      child: Divider(
                                          color: Colors.white.withOpacity(0.3))),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'OR',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      child: Divider(
                                          color: Colors.white.withOpacity(0.3))),
                                ],
                              ).animate().fadeIn(duration: 400.ms, delay: 1200.ms),

                              const SizedBox(height: 24),

                              // Create Account Button
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          const RoleSelectionScreen(),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        const begin = Offset(0.0, 1.0);
                                        const end = Offset.zero;
                                        const curve = Curves.easeInOutCubic;
                                        var tween = Tween(begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));
                                        var offsetAnimation =
                                            animation.drive(tween);
                                        return SlideTransition(
                                            position: offsetAnimation,
                                            child: child);
                                      },
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 16),
                                    side:
                                        BorderSide(color: FuturisticColors.primary),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Create New Account',
                                    style: TextStyle(
                                      color: FuturisticColors.primary,
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
                        ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideY(
                            begin: 0.3,
                            end: 0,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic),

                        const SizedBox(height: 20),

                        // Theme Switch Widget
                        ThemeSwitchWidget(
                          isDark: _isDark,
                          onChanged: (value) {
                            setState(() => _isDark = value);
                          },
                        ).animate().fadeIn(duration: 400.ms, delay: 1400.ms),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

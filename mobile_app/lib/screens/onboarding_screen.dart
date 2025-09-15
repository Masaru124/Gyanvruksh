import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gyanvruksh/theme/futuristic_theme.dart';
import 'package:gyanvruksh/widgets/glowing_button.dart';
import 'package:gyanvruksh/widgets/particle_background.dart';
import 'package:gyanvruksh/widgets/floating_elements.dart';
import 'package:gyanvruksh/widgets/animated_wave_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Welcome to Gyanvruksh',
      subtitle: 'Your gateway to knowledge and learning',
      description: 'Discover a revolutionary learning platform designed to empower your educational journey with cutting-edge technology and personalized experiences.',
      icon: FontAwesomeIcons.graduationCap,
      color: FuturisticColors.neonBlue,
      backgroundElements: [
        Icons.school,
        Icons.book,
        Icons.lightbulb,
        Icons.computer,
        Icons.star,
      ],
    ),
    OnboardingPageData(
      title: 'Interactive Learning',
      subtitle: 'Engage with dynamic content',
      description: 'Experience learning like never before with interactive courses, real-time collaboration, and AI-powered recommendations tailored just for you.',
      icon: FontAwesomeIcons.chalkboardTeacher,
      color: FuturisticColors.neonPurple,
      backgroundElements: [
        Icons.chat,
        Icons.video_call,
        Icons.forum,
        Icons.group,
        Icons.message,
      ],
    ),
    OnboardingPageData(
      title: 'Track Your Progress',
      subtitle: 'Monitor your learning journey',
      description: 'Stay motivated with detailed analytics, achievement badges, and personalized learning paths that adapt to your pace and preferences.',
      icon: FontAwesomeIcons.chartLine,
      color: FuturisticColors.neonGreen,
      backgroundElements: [
        Icons.bar_chart,
        Icons.timeline,
        Icons.trending_up,
        Icons.emoji_events,
        Icons.star_border,
      ],
    ),
    OnboardingPageData(
      title: 'Connect & Collaborate',
      subtitle: 'Learn together with peers',
      description: 'Join study groups, participate in discussions, and collaborate on projects with learners from around the world in our vibrant community.',
      icon: FontAwesomeIcons.users,
      color: FuturisticColors.warning,
      backgroundElements: [
        Icons.people,
        Icons.handshake,
        Icons.share,
        Icons.public,
        Icons.diversity_3,
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    // TODO: Implement persistent storage for onboarding completion
    // For now, just navigate to login screen
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Wave Background
          AnimatedWaveBackground(
            color: _pages[_currentPage].color.withOpacity(0.1),
            height: size.height,
          ),

          // Particle Background
          ParticleBackground(
            particleCount: 25,
            particleColor: _pages[_currentPage].color,
          ),

          // Floating Elements
          FloatingElements(
            elementCount: 6,
            maxElementSize: 50,
            icons: _pages[_currentPage].backgroundElements,
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip Button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: _pages[_currentPage].color,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),

                // Page View
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index]);
                    },
                  ),
                ),

                // Page Indicators
                _buildPageIndicators(),

                // Bottom Actions
                _buildBottomActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPageData pageData) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  pageData.color.withOpacity(0.3),
                  pageData.color.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: pageData.color.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: pageData.color.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              pageData.icon,
              size: 60,
              color: pageData.color,
            ),
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 40),

          // Title
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Text(
                  pageData.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: pageData.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            pageData.subtitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: pageData.color.withOpacity(0.8),
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),

          // Description
          Text(
            pageData.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              height: 1.6,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _pages.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? _pages[_currentPage].color
                  : _pages[_currentPage].color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Text(
                'Back',
                style: TextStyle(
                  color: _pages[_currentPage].color,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            const SizedBox(width: 60),

          // Next/Get Started Button
          GlowingButton(
            onPressed: _nextPage,
            width: 120,
            height: 50,
            child: Text(
              _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPageData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final List<IconData> backgroundElements;

  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.backgroundElements,
  });
}

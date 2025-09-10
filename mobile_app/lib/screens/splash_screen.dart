import 'package:flutter/material.dart';
import 'package:gyanvruksh/screens/login.dart';
import 'package:gyanvruksh/widgets/cinematic_intro.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CinematicIntro(
      introDuration: const Duration(seconds: 4),
      title: 'Gyanvruksh',
      subtitle: 'Tree of Knowledge',
      onIntroComplete: () {
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const LoginScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        }
      },
    );
  }
}

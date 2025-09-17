import 'package:flutter/material.dart';
import '../theme/futuristic_theme.dart';

class FlashcardWidget extends StatefulWidget {
  final String question;
  final String answer;
  final String? hint;

  const FlashcardWidget({
    super.key,
    required this.question,
    required this.answer,
    this.hint,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with TickerProviderStateMixin {
  bool _showAnswer = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showAnswer) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final isFront = _flipAnimation.value < 0.5;
          final rotationY = _flipAnimation.value * 3.14159;

          return Transform(
            transform: Matrix4.rotationY(rotationY),
            alignment: Alignment.center,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isFront
                      ? [
                          FuturisticColors.primary.withOpacity(0.8),
                          FuturisticColors.secondary.withOpacity(0.8),
                        ]
                      : [
                          FuturisticColors.surface,
                          FuturisticColors.surfaceContainerHighest,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isFront
                      ? FuturisticColors.primary.withOpacity(0.5)
                      : FuturisticColors.primary.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isFront ? FuturisticColors.primary : FuturisticColors.surface)
                        .withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Transform(
                transform: Matrix4.rotationY(isFront ? 0 : 3.14159),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      Icon(
                        isFront ? Icons.question_mark : Icons.lightbulb,
                        size: 48,
                        color: isFront
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),

                      const SizedBox(height: 16),

                      // Title
                      Text(
                        isFront ? 'Question' : 'Answer',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isFront
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            isFront ? widget.question : widget.answer,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isFront
                                  ? Colors.white.withOpacity(0.9)
                                  : theme.colorScheme.onSurface,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      // Hint (only show on front)
                      if (isFront && widget.hint != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '💡 ${widget.hint}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Tap instruction
                      Text(
                        isFront ? 'Tap to reveal answer' : 'Tap to see question',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isFront
                              ? Colors.white.withOpacity(0.7)
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

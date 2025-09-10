import 'package:flutter/material.dart';

class ParallaxScrollView extends StatefulWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool reverse;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Axis scrollDirection;

  const ParallaxScrollView({
    super.key,
    required this.children,
    this.controller,
    this.padding,
    this.reverse = false,
    this.physics,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
  });

  @override
  State<ParallaxScrollView> createState() => _ParallaxScrollViewState();
}

class _ParallaxScrollViewState extends State<ParallaxScrollView> {
  late ScrollController _scrollController;
  final Map<int, double> _parallaxOffsets = {};

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      // Update parallax offsets based on scroll position
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: widget.padding,
      reverse: widget.reverse,
      physics: widget.physics,
      scrollDirection: widget.scrollDirection,
      child: Column(
        children: widget.children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;

          return AnimatedBuilder(
            animation: _scrollController,
            builder: (context, childWidget) {
              final scrollOffset = _scrollController.hasClients
                  ? _scrollController.offset
                  : 0.0;

              // Calculate parallax effect
              final parallaxOffset = scrollOffset * (0.5 - index * 0.1);

              return Transform.translate(
                offset: Offset(0, parallaxOffset),
                child: childWidget,
              );
            },
            child: child,
          );
        }).toList(),
      ),
    );
  }
}

class FadeInOnScroll extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double startOffset;
  final Curve curve;

  const FadeInOnScroll({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.startOffset = 50.0,
    this.curve = Curves.easeOut,
  });

  @override
  State<FadeInOnScroll> createState() => _FadeInOnScrollState();
}

class _FadeInOnScrollState extends State<FadeInOnScroll>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.curve,
      ),
    );

    _slideAnimation = Tween<double>(begin: widget.startOffset, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.curve,
      ),
    );

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class StaggeredAnimationList extends StatelessWidget {
  final List<Widget> children;
  final Duration baseDelay;
  final Duration staggerDelay;
  final Duration duration;

  const StaggeredAnimationList({
    super.key,
    required this.children,
    this.baseDelay = const Duration(milliseconds: 100),
    this.staggerDelay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        final delay = baseDelay + (staggerDelay * index);

        return FadeInOnScroll(
          delay: delay,
          duration: duration,
          child: child,
        );
      }).toList(),
    );
  }
}

class ScaleOnHover extends StatefulWidget {
  final Widget child;
  final double scale;
  final Duration duration;
  final Curve curve;

  const ScaleOnHover({
    super.key,
    required this.child,
    this.scale = 1.05,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
  });

  @override
  State<ScaleOnHover> createState() => _ScaleOnHoverState();
}

class _ScaleOnHoverState extends State<ScaleOnHover>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.curve,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _animationController.forward(),
      onExit: (_) => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double scale;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.scale = 1.1,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

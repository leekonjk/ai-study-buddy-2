/// Smoke Splash Screen
/// Animated splash with particle smoke effect and logo reveal.
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';

/// Splash screen with smoke particle animation.
class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _smokeController;
  late AnimationController _logoController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _textFade;

  final List<_SmokeParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeParticles();
    _setupAnimations();
  }

  void _initializeParticles() {
    for (int i = 0; i < 50; i++) {
      _particles.add(
        _SmokeParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble() * 0.5 + 0.5, // Start from bottom half
          size: _random.nextDouble() * 60 + 20,
          speed: _random.nextDouble() * 0.3 + 0.1,
          opacity: _random.nextDouble() * 0.3 + 0.1,
          drift: (_random.nextDouble() - 0.5) * 0.2,
        ),
      );
    }
  }

  void _setupAnimations() {
    // Smoke animation - runs continuously
    _smokeController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    // Logo animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );

    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start logo animation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _logoController.forward();
    });

    // Navigate to next screen
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                widget.nextScreen,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _smokeController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: StudyBuddyColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Smoke particles
            AnimatedBuilder(
              animation: _smokeController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _SmokePainter(
                    particles: _particles,
                    animationValue: _smokeController.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),

            // Gradient overlay for depth
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    StudyBuddyColors.background.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),

            // Logo and text
            Center(
              child: AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo with glow
                      Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoFade.value,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  StudyBuddyColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  StudyBuddyColors.secondary.withValues(
                                    alpha: 0.2,
                                  ),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: StudyBuddyColors.primary.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                                BoxShadow(
                                  color: StudyBuddyColors.secondary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 60,
                                  spreadRadius: 5,
                                ),
                              ],
                              border: Border.all(
                                color: StudyBuddyColors.primary.withValues(
                                  alpha: 0.5,
                                ),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              size: 70,
                              color: StudyBuddyColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // App name
                      Opacity(
                        opacity: _textFade.value,
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              StudyBuddyColors.primary,
                              StudyBuddyColors.secondary,
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'AI Study Buddy',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tagline
                      Opacity(
                        opacity: _textFade.value,
                        child: const Text(
                          'Your intelligent learning companion',
                          style: TextStyle(
                            fontSize: 16,
                            color: StudyBuddyColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single smoke particle data.
class _SmokeParticle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;
  double drift;

  _SmokeParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.drift,
  });
}

/// Custom painter for smoke effect.
class _SmokePainter extends CustomPainter {
  final List<_SmokeParticle> particles;
  final double animationValue;

  _SmokePainter({required this.particles, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Calculate animated position
      final progress = (animationValue + particle.y) % 1.0;
      final x = (particle.x + particle.drift * animationValue) * size.width;
      final y = size.height * (1 - progress);

      // Fade out as particle rises
      final fadeProgress = 1 - progress;
      final currentOpacity = particle.opacity * fadeProgress;

      if (currentOpacity > 0.01) {
        final paint = Paint()
          ..color = StudyBuddyColors.primary.withValues(alpha: currentOpacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 0.5);

        canvas.drawCircle(
          Offset(x, y),
          particle.size * (0.5 + fadeProgress * 0.5),
          paint,
        );

        // Add secondary purple particles
        final paint2 = Paint()
          ..color = StudyBuddyColors.secondary.withValues(
            alpha: currentOpacity * 0.6,
          )
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 0.3);

        canvas.drawCircle(
          Offset(x + particle.size * 0.3, y - particle.size * 0.2),
          particle.size * 0.4 * fadeProgress,
          paint2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SmokePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

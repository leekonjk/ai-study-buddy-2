/// Mascot Widget
/// Animated blue blob character with expressions matching StudySmarter design.
library;

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Mascot expression types
enum MascotExpression { happy, thinking, speaking, neutral }

/// Mascot size variants
enum MascotSize {
  small(40.0),
  medium(60.0),
  large(80.0);

  final double value;
  const MascotSize(this.value);
}

/// Animated mascot widget with expressions and glow effect.
class MascotWidget extends StatefulWidget {
  final MascotExpression expression;
  final MascotSize size;
  final bool showGlow;

  const MascotWidget({
    super.key,
    this.expression = MascotExpression.happy,
    this.size = MascotSize.medium,
    this.showGlow = true,
  });

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _breathAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size.value,
          height: widget.size.value,
          decoration: widget.showGlow
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF06B6D4,
                      ).withValues(alpha: _glowAnimation.value),
                      blurRadius: widget.size.value * 0.8,
                      spreadRadius: widget.size.value * 0.2,
                    ),
                  ],
                )
              : null,
          child: Transform.scale(
            scale: _breathAnimation.value,
            child: CustomPaint(
              painter: _MascotPainter(
                expression: widget.expression,
                size: widget.size.value,
              ),
              size: Size(widget.size.value, widget.size.value),
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for mascot blob shape and face.
class _MascotPainter extends CustomPainter {
  final MascotExpression expression;
  final double size;

  _MascotPainter({required this.expression, required this.size});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = this.size / 2;

    // Draw blob body (blue blob shape)
    final bodyPath = Path();
    final blobRadius = radius * 0.9;

    // Create organic blob shape
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * math.pi) / 8;
      final variation = (i % 2 == 0) ? 1.0 : 0.85;
      final x = center.dx + math.cos(angle) * blobRadius * variation;
      final y = center.dy + math.sin(angle) * blobRadius * variation;

      if (i == 0) {
        bodyPath.moveTo(x, y);
      } else {
        bodyPath.lineTo(x, y);
      }
    }
    bodyPath.close();

    final bodyPaint = Paint()
      ..color = const Color(0xFF06B6D4)
      ..style = PaintingStyle.fill;

    canvas.drawPath(bodyPath, bodyPaint);

    // Draw face based on expression
    _drawFace(canvas, center, radius);
  }

  void _drawFace(Canvas canvas, Offset center, double radius) {
    final eyeRadius = radius * 0.08;
    final eyeDistance = radius * 0.25;
    final mouthWidth = radius * 0.3;
    final mouthHeight = radius * 0.15;

    final facePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    switch (expression) {
      case MascotExpression.happy:
        // Happy eyes (circles)
        canvas.drawCircle(
          Offset(center.dx - eyeDistance, center.dy - radius * 0.1),
          eyeRadius,
          facePaint,
        );
        canvas.drawCircle(
          Offset(center.dx + eyeDistance, center.dy - radius * 0.1),
          eyeRadius,
          facePaint,
        );

        // Happy mouth (smile arc)
        final smilePath = Path();
        smilePath.addArc(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + radius * 0.15),
            width: mouthWidth,
            height: mouthHeight,
          ),
          math.pi * 0.2,
          math.pi * 0.6,
        );
        final smilePaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.05;
        canvas.drawPath(smilePath, smilePaint);
        break;

      case MascotExpression.thinking:
        // Thinking eyes (smaller, looking up)
        canvas.drawCircle(
          Offset(center.dx - eyeDistance, center.dy - radius * 0.15),
          eyeRadius * 0.8,
          facePaint,
        );
        canvas.drawCircle(
          Offset(center.dx + eyeDistance, center.dy - radius * 0.15),
          eyeRadius * 0.8,
          facePaint,
        );

        // Thinking mouth (straight line)
        canvas.drawLine(
          Offset(center.dx - mouthWidth / 2, center.dy + radius * 0.2),
          Offset(center.dx + mouthWidth / 2, center.dy + radius * 0.2),
          Paint()
            ..color = Colors.white
            ..strokeWidth = radius * 0.05,
        );
        break;

      case MascotExpression.speaking:
        // Speaking eyes (normal)
        canvas.drawCircle(
          Offset(center.dx - eyeDistance, center.dy - radius * 0.1),
          eyeRadius,
          facePaint,
        );
        canvas.drawCircle(
          Offset(center.dx + eyeDistance, center.dy - radius * 0.1),
          eyeRadius,
          facePaint,
        );

        // Speaking mouth (oval, open)
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + radius * 0.2),
            width: mouthWidth * 0.6,
            height: mouthHeight * 1.2,
          ),
          facePaint,
        );
        break;

      case MascotExpression.neutral:
        // Neutral eyes (normal)
        canvas.drawCircle(
          Offset(center.dx - eyeDistance, center.dy - radius * 0.1),
          eyeRadius,
          facePaint,
        );
        canvas.drawCircle(
          Offset(center.dx + eyeDistance, center.dy - radius * 0.1),
          eyeRadius,
          facePaint,
        );

        // Neutral mouth (straight line)
        canvas.drawLine(
          Offset(center.dx - mouthWidth / 2, center.dy + radius * 0.15),
          Offset(center.dx + mouthWidth / 2, center.dy + radius * 0.15),
          Paint()
            ..color = Colors.white
            ..strokeWidth = radius * 0.05,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(_MascotPainter oldDelegate) {
    return oldDelegate.expression != expression || oldDelegate.size != size;
  }
}

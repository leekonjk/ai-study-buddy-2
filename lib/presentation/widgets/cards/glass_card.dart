/// Glass Card Widget
/// A glassmorphism-style card with blur effect and gradient border.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/app_theme.dart';

/// A glass-effect card with optional gradient border and blur.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? backgroundColor;
  final Gradient? gradient;
  final bool showBorder;
  final Color? borderColor;
  final double blurAmount;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.backgroundColor,
    this.gradient,
    this.showBorder = true,
    this.borderColor,
    this.blurAmount = 10,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                padding: padding ?? const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient:
                      gradient ??
                      LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          (backgroundColor ?? AppColors.cardBackground)
                              .withValues(alpha: 0.8),
                          (backgroundColor ?? AppColors.cardBackground)
                              .withValues(alpha: 0.6),
                        ],
                      ),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: showBorder
                      ? Border.all(
                          color:
                              borderColor ??
                              AppColors.border.withValues(alpha: 0.5),
                          width: 1,
                        )
                      : null,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A glass card variant with accent gradient for highlighting.
class AccentGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color accentColor;
  final VoidCallback? onTap;

  const AccentGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.accentColor = AppColors.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: GlassCard(
        padding: padding,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.15),
            accentColor.withValues(alpha: 0.05),
          ],
        ),
        borderColor: accentColor.withValues(alpha: 0.3),
        onTap: onTap,
        child: child,
      ),
    );
  }
}

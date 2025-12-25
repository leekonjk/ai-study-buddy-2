/// Flip Card Widget
/// 3D animated card flip for flashcard study.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/app_theme.dart';
import 'package:studnet_ai_buddy/presentation/widgets/cards/glass_card.dart';

/// A 3D flip card widget for flashcard interactions.
class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final Duration duration;
  final VoidCallback? onFlip;
  final FlipCardController? controller;

  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 400),
    this.onFlip,
    this.controller,
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    widget.controller?._state = this;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isAnimating) return;

    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
    widget.onFlip?.call();
  }

  void reset() {
    _controller.reset();
    _isFront = true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final isFrontVisible = angle < math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(angle),
            child: isFrontVisible
                ? widget.front
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: widget.back,
                  ),
          );
        },
      ),
    );
  }
}

/// Controller for FlipCard widget.
class FlipCardController {
  _FlipCardState? _state;

  void flip() => _state?._flip();
  void reset() => _state?.reset();
  bool get isFront => _state?._isFront ?? true;
}

/// Styled flashcard for studying.
class StudyFlashcard extends StatelessWidget {
  final String text;
  final bool isFront;
  final Color? accentColor;

  const StudyFlashcard({
    super.key,
    required this.text,
    this.isFront = true,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        accentColor ?? (isFront ? AppColors.primary : AppColors.secondary);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 200),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderColor: color.withValues(alpha: 0.3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isFront ? 'TERM' : 'DEFINITION',
                style: AppTypography.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Content
            Text(
              text,
              style: AppTypography.headline3.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            // Tap hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Tap to flip',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Difficulty rating buttons for flashcard study.
class DifficultyButtons extends StatelessWidget {
  final ValueChanged<FlashcardDifficulty>? onSelect;

  const DifficultyButtons({super.key, this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DifficultyButton(
            label: 'Hard',
            sublabel: '< 1 min',
            color: AppColors.error,
            onTap: () => onSelect?.call(FlashcardDifficulty.hard),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _DifficultyButton(
            label: 'Good',
            sublabel: '< 10 min',
            color: AppColors.warning,
            onTap: () => onSelect?.call(FlashcardDifficulty.good),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _DifficultyButton(
            label: 'Easy',
            sublabel: '4 days',
            color: AppColors.success,
            onTap: () => onSelect?.call(FlashcardDifficulty.easy),
          ),
        ),
      ],
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback? onTap;

  const _DifficultyButton({
    required this.label,
    required this.sublabel,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            children: [
              Text(
                label,
                style: AppTypography.subtitle2.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum FlashcardDifficulty { easy, good, hard }

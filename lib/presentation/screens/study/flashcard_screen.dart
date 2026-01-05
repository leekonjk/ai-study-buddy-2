/// Flashcard Study Screen
/// Interactive flashcard study session with swipe gestures and flip animations.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/entities/flashcard.dart';
import 'package:studnet_ai_buddy/domain/repositories/flashcard_repository.dart';
import 'package:studnet_ai_buddy/presentation/theme/app_theme.dart';
import 'package:studnet_ai_buddy/presentation/widgets/common/progress_ring.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/gradient_scaffold.dart';
import 'package:studnet_ai_buddy/presentation/widgets/common/loading_indicator.dart'; // Added import

/// Flashcard study session screen with swipe gestures.
class FlashcardScreen extends StatefulWidget {
  final String studySetId;
  final String studySetTitle;

  const FlashcardScreen({
    super.key,
    required this.studySetId,
    required this.studySetTitle,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with TickerProviderStateMixin {
  List<Flashcard> _flashcards = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _isFlipped = false;

  // Swipe animation
  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;
  late Animation<double> _rotationAnimation;
  Offset _dragOffset = Offset.zero;
  // ignore: unused_field - used for pan gesture state tracking
  bool _isDragging = false;

  // Stats
  int _knownCount = 0;
  int _unknownCount = 0;

  // Track results for each flashcard: flashcardId -> known(true)/unknown(false)
  final Map<String, bool> _flashcardResults = {};

  @override
  void initState() {
    super.initState();
    _setupSwipeAnimation();
    _loadFlashcards();
  }

  void _setupSwipeAnimation() {
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(_swipeController);
  }

  Future<void> _loadFlashcards() async {
    final result = await getIt<FlashcardRepository>().getFlashcardsByStudySetId(
      widget.studySetId,
    );

    result.fold(
      onSuccess: (cards) {
        setState(() {
          if (cards.isEmpty) {
            // Use demo data if no cards exist
            _flashcards = _getDemoFlashcards();
          } else {
            _flashcards = cards;
          }
          _isLoading = false;
        });
      },
      onFailure: (_) {
        setState(() {
          _flashcards = _getDemoFlashcards();
          _isLoading = false;
        });
      },
    );
  }

  List<Flashcard> _getDemoFlashcards() {
    final now = DateTime.now();
    return [
      Flashcard(
        id: '1',
        studySetId: widget.studySetId,
        term: 'Photosynthesis',
        definition:
            'The process by which plants convert light energy into chemical energy',
        creatorId: 'demo',
        createdAt: now,
        lastUpdated: now,
      ),
      Flashcard(
        id: '2',
        studySetId: widget.studySetId,
        term: 'Mitochondria',
        definition: 'The powerhouse of the cell, responsible for producing ATP',
        creatorId: 'demo',
        createdAt: now,
        lastUpdated: now,
      ),
      Flashcard(
        id: '3',
        studySetId: widget.studySetId,
        term: 'DNA',
        definition: 'Deoxyribonucleic acid - carries genetic information',
        creatorId: 'demo',
        createdAt: now,
        lastUpdated: now,
      ),
      Flashcard(
        id: '4',
        studySetId: widget.studySetId,
        term: 'Osmosis',
        definition:
            'Movement of water molecules through a semipermeable membrane',
        creatorId: 'demo',
        createdAt: now,
        lastUpdated: now,
      ),
      Flashcard(
        id: '5',
        studySetId: widget.studySetId,
        term: 'Enzyme',
        definition: 'A protein that acts as a biological catalyst',
        creatorId: 'demo',
        createdAt: now,
        lastUpdated: now,
      ),
    ];
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.3;

    if (_dragOffset.dx.abs() > threshold) {
      // Swipe completed
      final isRight = _dragOffset.dx > 0;
      _animateSwipeOut(isRight);
    } else {
      // Snap back
      _animateSnapBack();
    }
    setState(() {
      _isDragging = false;
    });
  }

  void _animateSwipeOut(bool isRight) {
    final screenWidth = MediaQuery.of(context).size.width;
    final targetX = isRight ? screenWidth * 1.5 : -screenWidth * 1.5;

    _swipeAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset(targetX, _dragOffset.dy),
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));

    _rotationAnimation = Tween<double>(
      begin: _dragOffset.dx / screenWidth * 0.3,
      end: isRight ? 0.5 : -0.5,
    ).animate(_swipeController);

    _swipeController.forward(from: 0).then((_) {
      _handleSwipeComplete(isRight);
    });
  }

  void _animateSnapBack() {
    _swipeAnimation = Tween<Offset>(begin: _dragOffset, end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _swipeController, curve: Curves.elasticOut),
        );

    _rotationAnimation = Tween<double>(
      begin: _dragOffset.dx / MediaQuery.of(context).size.width * 0.3,
      end: 0,
    ).animate(_swipeController);

    _swipeController.forward(from: 0).then((_) {
      setState(() {
        _dragOffset = Offset.zero;
      });
    });
  }

  void _handleSwipeComplete(bool known) {
    // Track this flashcard's result
    final currentCard = _flashcards[_currentIndex];
    _flashcardResults[currentCard.id] = known;

    setState(() {
      if (known) {
        _knownCount++;
      } else {
        _unknownCount++;
      }

      _dragOffset = Offset.zero;
      _isFlipped = false;

      if (_currentIndex < _flashcards.length - 1) {
        _currentIndex++;
      } else {
        _showResults();
      }
    });
  }

  void _onSwipeButton(bool known) {
    _animateSwipeOut(known);
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _showResults() {
    // Save progress to Firestore
    _saveProgress();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ResultsSheet(
        total: _flashcards.length,
        known: _knownCount,
        unknown: _unknownCount,
        onContinue: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        onRetry: () {
          Navigator.pop(context);
          setState(() {
            _currentIndex = 0;
            _knownCount = 0;
            _unknownCount = 0;
            _isFlipped = false;
            _dragOffset = Offset.zero;
            _flashcardResults.clear();
          });
        },
      ),
    );
  }

  Future<void> _saveProgress() async {
    if (_flashcardResults.isEmpty) return;

    try {
      final repository = getIt<FlashcardRepository>();
      await repository.updateFlashcardsProgressBatch(_flashcardResults);
    } catch (e) {
      // Silently fail - progress tracking is not critical
      debugPrint('Failed to save flashcard progress: $e');
    }
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const GradientScaffold(body: Center(child: LoadingIndicator()));
    }

    final progress = (_currentIndex + 1) / _flashcards.length;
    final screenWidth = MediaQuery.of(context).size.width;

    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(progress),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: MiniProgress(
                progress: progress,
                color: AppColors.primary,
                height: 6,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Swipe indicators
            _buildSwipeIndicators(),

            // Flashcard stack
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background cards (stack effect)
                  if (_currentIndex < _flashcards.length - 1)
                    Transform.scale(
                      scale: 0.95,
                      child: Opacity(
                        opacity: 0.5,
                        child: _buildCard(
                          _flashcards[_currentIndex + 1],
                          isFlipped: false,
                        ),
                      ),
                    ),

                  // Current card with swipe
                  AnimatedBuilder(
                    animation: _swipeController,
                    builder: (context, child) {
                      final offset = _swipeController.isAnimating
                          ? _swipeAnimation.value
                          : _dragOffset;
                      final rotation = _swipeController.isAnimating
                          ? _rotationAnimation.value
                          : _dragOffset.dx / screenWidth * 0.3;

                      return Transform.translate(
                        offset: offset,
                        child: Transform.rotate(
                          angle: rotation,
                          child: GestureDetector(
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                            onTap: _flipCard,
                            child: Stack(
                              children: [
                                _buildCard(
                                  _flashcards[_currentIndex],
                                  isFlipped: _isFlipped,
                                ),
                                // Swipe feedback overlays
                                _buildSwipeOverlay(offset.dx, screenWidth),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Bottom buttons
            _buildBottomButtons(),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double progress) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.studySetTitle,
                  style: AppTypography.subtitle2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '${_currentIndex + 1} of ${_flashcards.length}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.shuffle_rounded,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeIndicators() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.arrow_back_rounded, size: 14, color: AppColors.error),
              const SizedBox(width: 4),
              Text(
                'Don\'t know',
                style: AppTypography.caption.copyWith(color: AppColors.error),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Know',
                style: AppTypography.caption.copyWith(color: AppColors.success),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Flashcard card, {required bool isFlipped}) {
    return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              final rotate = Tween(begin: 1.0, end: 0.0).animate(animation);
              return AnimatedBuilder(
                animation: rotate,
                child: child,
                builder: (context, child) {
                  final isUnder = rotate.value > 0.5;
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(rotate.value * 3.14159),
                    alignment: Alignment.center,
                    child: isUnder ? child : child,
                  );
                },
              );
            },
            child: Container(
              key: ValueKey(isFlipped),
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 280),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (isFlipped ? AppColors.secondary : AppColors.primary)
                        .withValues(alpha: 0.15),
                    AppColors.cardBackground,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: (isFlipped ? AppColors.secondary : AppColors.primary)
                      .withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Label
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (isFlipped ? AppColors.secondary : AppColors.primary)
                              .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isFlipped ? 'DEFINITION' : 'TERM',
                      style: AppTypography.caption.copyWith(
                        color: isFlipped
                            ? AppColors.secondary
                            : AppColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: Text(
                      isFlipped ? card.definition : card.term,
                      style: AppTypography.headline3.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
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
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildSwipeOverlay(double offsetX, double screenWidth) {
    final progress = (offsetX.abs() / (screenWidth * 0.3)).clamp(0.0, 1.0);
    final isRight = offsetX > 0;

    if (progress < 0.1) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: (isRight ? AppColors.success : AppColors.error).withValues(
              alpha: progress * 0.8,
            ),
            width: 3,
          ),
        ),
        child: Center(
          child: Opacity(
            opacity: progress,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: (isRight ? AppColors.success : AppColors.error)
                    .withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isRight ? 'KNOW ✓' : 'DON\'T KNOW ✗',
                style: AppTypography.subtitle1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          // Don't Know button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _onSwipeButton(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error.withValues(alpha: 0.15),
                foregroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.close_rounded),
              label: const Text('Don\'t Know'),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Know button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _onSwipeButton(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success.withValues(alpha: 0.15),
                foregroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.check_rounded),
              label: const Text('Know'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Results sheet shown after completing study session.
class _ResultsSheet extends StatelessWidget {
  final int total;
  final int known;
  final int unknown;
  final VoidCallback onContinue;
  final VoidCallback onRetry;

  const _ResultsSheet({
    required this.total,
    required this.known,
    required this.unknown,
    required this.onContinue,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = total > 0 ? known / total : 0.0;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Progress ring
          ProgressRing(
            progress: accuracy,
            size: 120,
            strokeWidth: 12,
            progressColor: accuracy >= 0.7
                ? AppColors.success
                : AppColors.warning,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(accuracy * 100).toInt()}%',
                  style: AppTypography.headline2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Mastered',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Title
          Text(
            accuracy >= 0.7 ? 'Great Job! 🎉' : 'Keep Practicing! 💪',
            style: AppTypography.headline3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatChip(
                icon: Icons.check_circle_rounded,
                label: '$known known',
                color: AppColors.success,
              ),
              const SizedBox(width: AppSpacing.lg),
              _StatChip(
                icon: Icons.refresh_rounded,
                label: '$unknown to review',
                color: AppColors.warning,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  child: Text(
                    'Study Again',
                    style: AppTypography.button.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: AppTypography.button.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

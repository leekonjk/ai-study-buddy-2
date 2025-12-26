/// Add Flashcards Screen
/// Screen for adding multiple flashcards to a study set.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';
import 'package:studnet_ai_buddy/presentation/navigation/main_shell.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/entities/flashcard.dart';
import 'package:studnet_ai_buddy/domain/services/ai_mentor_service.dart';
import 'package:studnet_ai_buddy/core/utils/result.dart'; // Added for Err type

import 'package:studnet_ai_buddy/domain/repositories/academic_repository.dart';
import 'package:studnet_ai_buddy/presentation/navigation/app_router.dart'; // Added

/// Data class for a flashcard being created.
class FlashcardData {
  String term;
  String definition;
  final TextEditingController termController;
  final TextEditingController definitionController;

  FlashcardData({this.term = '', this.definition = ''})
    : termController = TextEditingController(text: term),
      definitionController = TextEditingController(text: definition);

  void dispose() {
    termController.dispose();
    definitionController.dispose();
  }

  bool get isValid => term.trim().isNotEmpty && definition.trim().isNotEmpty;
  bool get isEmpty => term.trim().isEmpty && definition.trim().isEmpty;
}

/// Screen to add flashcards to a study set.
class AddFlashcardsScreen extends StatefulWidget {
  final String studySetTitle;
  final String studySetCategory;
  final String studySetDescription;
  final String? subjectId; // Added subjectId
  final bool isPrivate;
  final bool autoStartAI;

  const AddFlashcardsScreen({
    super.key,
    required this.studySetTitle,
    required this.studySetCategory,
    required this.studySetDescription,
    this.subjectId, // Added
    required this.isPrivate,
    this.autoStartAI = false,
  });

  @override
  State<AddFlashcardsScreen> createState() => _AddFlashcardsScreenState();
}

class _AddFlashcardsScreenState extends State<AddFlashcardsScreen> {
  final List<FlashcardData> _flashcards = [];
  final ScrollController _scrollController = ScrollController();
  bool _isSaving = false;
  bool _isGenerating = false;
  String _createdStudySetId = '';

  // Inject AI Service
  final _aiMentorService = getIt<AIMentorService>();

  @override
  void initState() {
    super.initState();
    if (widget.autoStartAI) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Delay slightly to allow screen transition to finish
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _generateWithAI();
        });
      });
    }
  }

  Future<void> _generateWithAI() async {
    // Show dialog to get card count
    int? count = await showDialog<int>(
      context: context,
      builder: (context) {
        int selectedCount = 5;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: StudyBuddyColors.cardBackground,
              title: const Text(
                'Generate Flashcards',
                style: TextStyle(color: StudyBuddyColors.textPrimary),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'How many cards do you want?',
                    style: TextStyle(color: StudyBuddyColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$selectedCount',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: StudyBuddyColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: selectedCount.toDouble(),
                    min: 3,
                    max: 20,
                    divisions: 17,
                    activeColor: StudyBuddyColors.primary,
                    onChanged: (val) {
                      setState(() => selectedCount = val.toInt());
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, selectedCount),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StudyBuddyColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Generate'),
                ),
              ],
            );
          },
        );
      },
    );

    if (count == null) return;

    setState(() => _isGenerating = true);
    try {
      // Get user's enrolled subjects for context
      final academicRepo = getIt<AcademicRepository>();
      final subjectsResult = await academicRepo.getEnrolledSubjects();

      String contextTopics = widget.studySetTitle;
      subjectsResult.fold(
        onSuccess: (subjects) {
          // 1. Try to find the specific selected subject
          if (widget.subjectId != null) {
            final specificSubject = subjects
                .where((s) => s.id == widget.subjectId)
                .firstOrNull;

            if (specificSubject != null) {
              contextTopics =
                  'Subject: ${specificSubject.name}. Topic: ${widget.studySetTitle}';
              return;
            }
          }

          // 2. Fallback to all enrolled subjects
          if (subjects.isNotEmpty) {
            final subjectNames = subjects.map((s) => s.name).join(', ');
            contextTopics =
                'Subject(s): $subjectNames. Topic: ${widget.studySetTitle}';
          }
        },
        onFailure: (_) {
          // Fallback to just the title
          contextTopics = widget.studySetTitle;
        },
      );

      final results = await _aiMentorService.generateFlashcardsFromTopics(
        topics: contextTopics, // Now includes real subject context!
        difficulty: 'medium',
        count: count,
      );

      // Convert to FlashcardData
      final newCards = results
          .map(
            (data) => FlashcardData(
              term: data['term'] ?? '',
              definition: data['definition'] ?? '',
            ),
          )
          .toList();

      setState(() {
        // Remove empty initial cards if we have AI results
        if (_flashcards.length <= 2 && _flashcards.every((c) => c.isEmpty)) {
          _flashcards.clear();
        }
        _flashcards.addAll(newCards);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generated ${newCards.length} flashcards!'),
            backgroundColor: StudyBuddyColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('AI Generation failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final card in _flashcards) {
      card.dispose();
    }
    super.dispose();
  }

  void _addFlashcard() {
    setState(() {
      _flashcards.add(FlashcardData());
    });

    // Scroll to the new card
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _removeFlashcard(int index) {
    if (_flashcards.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need at least one flashcard'),
          backgroundColor: StudyBuddyColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _flashcards[index].dispose();
      _flashcards.removeAt(index);
    });
  }

  void _updateFlashcard(int index, {String? term, String? definition}) {
    setState(() {
      if (term != null) _flashcards[index].term = term;
      if (definition != null) _flashcards[index].definition = definition;
    });
  }

  int get _validCardCount => _flashcards.where((card) => card.isValid).length;

  Future<void> _saveStudySet() async {
    final validCards = _flashcards.where((card) => card.isValid).toList();

    if (validCards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one complete flashcard'),
          backgroundColor: StudyBuddyColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Save to repositories
    try {
      // 1. Create Study Set
      final studySetResult = await studySetRepository.createStudySet(
        title: widget.studySetTitle,
        category: widget.studySetCategory,
        subjectId: widget.subjectId, // Pass subjectId
        isPrivate: widget.isPrivate,
      );

      if (studySetResult.isFailure) {
        // Show error message to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed: ${(studySetResult as Err).failure.message}',
              ),
              backgroundColor: StudyBuddyColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      String studySetId = '';
      studySetResult.fold(
        onSuccess: (val) {
          studySetId = val.id;
          _createdStudySetId = val.id;
        },
        onFailure: (_) {},
      );

      // 2. Create Flashcards
      final flashcardsToCreate = validCards.map((cardData) {
        final now = DateTime.now();
        return Flashcard(
          id:
              DateTime.now().millisecondsSinceEpoch.toString() +
              validCards
                  .indexOf(cardData)
                  .toString(), // Temporary ID, will be replaced by Firestore
          studySetId: studySetId,
          term: cardData.term,
          definition: cardData.definition,
          creatorId: '', // Repository will overwrite this with auth user ID
          createdAt: now,
          lastUpdated: now,
        );
      }).toList();

      // Use batch create if available or loop
      await flashcardRepository.createFlashcardsBatch(flashcardsToCreate);

      // 3. Update StudySet counts (optional, if not computed triggers)
      for (var card in flashcardsToCreate) {
        await studySetRepository.addFlashcard(studySetId, card.id);
      }

      // Success! Show dialog
      if (mounted) {
        setState(() => _isSaving = false);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _buildSuccessDialog(validCards.length),
        );
      }
    } catch (e) {
      debugPrint('Error saving study set: $e');

      // Show error to user
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save study set: ${e.toString()}'),
            backgroundColor: StudyBuddyColors.error,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _saveStudySet,
            ),
          ),
        );
      }
    }
  }

  Widget _buildSuccessDialog(int cardCount) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: StudyBuddyColors.cardBackground,
          borderRadius: StudyBuddyDecorations.borderRadiusL,
          border: Border.all(color: StudyBuddyColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: StudyBuddyColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: StudyBuddyColors.success,
                size: 48,
              ),
            ).animate().scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              curve: Curves.elasticOut,
              duration: 600.ms,
            ),
            const SizedBox(height: 24),
            const Text(
              'Study Set Created!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: StudyBuddyColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"${widget.studySetTitle}" with $cardCount flashcard${cardCount > 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 14,
                color: StudyBuddyColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MainShell()),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: StudyBuddyColors.textSecondary,
                      side: const BorderSide(color: StudyBuddyColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: StudyBuddyDecorations.borderRadiusFull,
                      ),
                    ),
                    child: const Text('Go Home'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to study set detail screen
                      Navigator.of(context).pushReplacementNamed(
                        AppRoutes.studySetDetail,
                        arguments: {
                          'studySetId': _createdStudySetId,
                          'title': widget.studySetTitle,
                          'category': widget.studySetCategory,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StudyBuddyColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: StudyBuddyDecorations.borderRadiusFull,
                      ),
                    ),
                    child: const Text('View Set'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: StudyBuddyColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Card count indicator
              _buildCardCountIndicator(),

              // Flashcard list or Empty State
              Expanded(
                child: _flashcards.isEmpty
                    ? _buildAIEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                        itemCount: _flashcards.length + 1, // +1 for add button
                        itemBuilder: (context, index) {
                          if (index == _flashcards.length) {
                            return _buildAddCardButton();
                          }
                          return _buildFlashcardEditor(index)
                              .animate()
                              .fadeIn(delay: (index * 50).ms)
                              .slideY(begin: 0.1, end: 0);
                        },
                      ),
              ),

              // Bottom button
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: StudyBuddyColors.cardBackground,
                borderRadius: StudyBuddyDecorations.borderRadiusS,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: StudyBuddyColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Flashcards',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: StudyBuddyColors.textPrimary,
                  ),
                ),
                Text(
                  widget.studySetTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: StudyBuddyColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // AI Button
          if (_isGenerating)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            TextButton.icon(
              onPressed: _generateWithAI,
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: const Text('AI Auto-Fill'),
              style: TextButton.styleFrom(
                foregroundColor: StudyBuddyColors.secondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardCountIndicator() {
    final total = _flashcards.length;
    final valid = _validCardCount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        borderRadius: StudyBuddyDecorations.borderRadiusFull,
        border: Border.all(color: StudyBuddyColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.style_rounded,
            size: 18,
            color: valid > 0
                ? StudyBuddyColors.success
                : StudyBuddyColors.textTertiary,
          ),
          const SizedBox(width: 8),
          Text(
            '$valid of $total cards complete',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valid > 0
                  ? StudyBuddyColors.success
                  : StudyBuddyColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardEditor(int index) {
    final card = _flashcards[index];
    final isComplete = card.isValid;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        borderRadius: StudyBuddyDecorations.borderRadiusL,
        border: Border.all(
          color: isComplete
              ? StudyBuddyColors.success.withValues(alpha: 0.5)
              : StudyBuddyColors.border,
          width: isComplete ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isComplete
                  ? StudyBuddyColors.success.withValues(alpha: 0.1)
                  : StudyBuddyColors.background.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isComplete
                        ? StudyBuddyColors.success
                        : StudyBuddyColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isComplete
                        ? const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Colors.white,
                          )
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: StudyBuddyColors.primary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Card ${index + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isComplete
                        ? StudyBuddyColors.success
                        : StudyBuddyColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _removeFlashcard(index),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: StudyBuddyColors.error,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // Term input
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Term',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: StudyBuddyColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: StudyBuddyColors.background,
                    borderRadius: StudyBuddyDecorations.borderRadiusM,
                    border: Border.all(
                      color: StudyBuddyColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  child: TextField(
                    controller: card.termController,
                    style: const TextStyle(
                      color: StudyBuddyColors.textPrimary,
                      fontSize: 16,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter term or question...',
                      hintStyle: TextStyle(
                        color: StudyBuddyColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                    onChanged: (value) => _updateFlashcard(index, term: value),
                  ),
                ),
                const SizedBox(height: 16),

                // Definition input
                const Text(
                  'Definition',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: StudyBuddyColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: StudyBuddyColors.background,
                    borderRadius: StudyBuddyDecorations.borderRadiusM,
                    border: Border.all(
                      color: StudyBuddyColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  child: TextField(
                    controller: card.definitionController,
                    style: const TextStyle(
                      color: StudyBuddyColors.textPrimary,
                      fontSize: 16,
                    ),
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Enter definition or answer...',
                      hintStyle: TextStyle(
                        color: StudyBuddyColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                    onChanged: (value) =>
                        _updateFlashcard(index, definition: value),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCardButton() {
    return GestureDetector(
      onTap: _addFlashcard,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: StudyBuddyColors.cardBackground,
          borderRadius: StudyBuddyDecorations.borderRadiusL,
          border: Border.all(
            color: StudyBuddyColors.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: StudyBuddyColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: StudyBuddyColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Add Another Card',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: StudyBuddyColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    final validCount = _validCardCount;
    final isValid = validCount > 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        border: Border(
          top: BorderSide(
            color: StudyBuddyColors.border.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isValid ? _saveStudySet : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: StudyBuddyColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: isValid ? 4 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: StudyBuddyDecorations.borderRadiusFull,
              ),
              disabledBackgroundColor: StudyBuddyColors.primary.withValues(
                alpha: 0.3,
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Text(
                    'Save Study Set ($validCount Cards)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: StudyBuddyColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 48,
                color: StudyBuddyColors.primary,
              ),
            ).animate().scale(
              delay: 200.ms,
              duration: 600.ms,
              curve: Curves.elasticOut,
            ),
            const SizedBox(height: 24),
            const Text(
              'Let AI do the work!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: StudyBuddyColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Generate flashcards instantly from your topic. No manual typing needed.',
              style: TextStyle(
                fontSize: 16,
                color: StudyBuddyColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _generateWithAI,
                icon: const Icon(Icons.bolt_rounded),
                label: const Text(
                  'Generate with AI',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: StudyBuddyColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: StudyBuddyColors.primary.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: StudyBuddyDecorations.borderRadiusFull,
                  ),
                ),
              ),
            ).animate().shimmer(delay: 1000.ms, duration: 1500.ms),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: _addFlashcard,
              icon: const Icon(Icons.edit_note_rounded, size: 18),
              label: const Text('Create Manually'),
              style: TextButton.styleFrom(
                foregroundColor: StudyBuddyColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

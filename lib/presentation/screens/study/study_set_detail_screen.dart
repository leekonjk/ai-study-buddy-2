import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studnet_ai_buddy/domain/entities/note.dart';
import 'package:studnet_ai_buddy/domain/entities/flashcard.dart';
import 'package:studnet_ai_buddy/domain/repositories/note_repository.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart'; // Guessing, will be verified by grep
import 'package:studnet_ai_buddy/presentation/navigation/app_router.dart';
import 'package:studnet_ai_buddy/presentation/widgets/common/loading_indicator.dart';
import 'package:get_it/get_it.dart';
import 'package:studnet_ai_buddy/domain/repositories/flashcard_repository.dart';

class StudySetDetailScreen extends StatefulWidget {
  final String studySetId;
  final String? title;
  final String? category;
  final int? cardCount;

  const StudySetDetailScreen({
    super.key,
    required this.studySetId,
    this.title,
    this.category,
    this.cardCount,
  });

  @override
  State<StudySetDetailScreen> createState() => _StudySetDetailScreenState();
}

class _StudySetDetailScreenState extends State<StudySetDetailScreen> {
  // State
  List<Flashcard> _flashcards = [];
  List<Note> _notes = [];
  bool _isLoading = true;
  String _title = '';
  String _category = '';
  int _masteredCount = 0;
  int _learningCount = 0;

  // Repository
  final _flashcardRepository = GetIt.I<FlashcardRepository>();
  final _noteRepository = GetIt.I<NoteRepository>();
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _title = widget.title ?? 'Study Set';
    _category = widget.category ?? 'General';
    _loadFlashcards();
    _loadNotes();
  }

  Future<void> _loadFlashcards() async {
    // ... existing implementation
    final result = await _flashcardRepository.getFlashcardsByStudySetId(
      widget.studySetId,
    );

    if (mounted) {
      setState(() {
        result.fold(
          onSuccess: (cards) {
            _flashcards = cards;
            // Calculate mastered count based on repetitions >= 3
            _masteredCount = cards.where((card) => card.isMastered).length;
            // Calculate learning count (at least 1 repetition but not mastered)
            _learningCount = cards
                .where((card) => card.repetitions > 0 && !card.isMastered)
                .length;
          },
          onFailure: (_) {
            _flashcards = [];
            _masteredCount = 0;
            _learningCount = 0;
          },
        );
        _isLoading = false;
      });
    }
  }

  void _loadNotes() {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      _noteRepository.watchNotes(userId).listen((allNotes) {
        if (mounted) {
          setState(() {
            _notes = allNotes
                .where((n) => n.studySetId == widget.studySetId)
                .toList();
          });
        }
      });
    }
  }

  // ... existing methods

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: LoadingIndicator()));
    }

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

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ... existing widgets
                      _buildInfoCard().animate().fadeIn().slideY(
                        begin: 0.1,
                        end: 0,
                      ),
                      const SizedBox(height: 24),

                      // Progress section
                      _buildProgressSection()
                          .animate()
                          .fadeIn(delay: 100.ms)
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),

                      // Quick actions
                      _buildQuickActions()
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),

                      // Notes Section
                      if (_notes.isNotEmpty) ...[
                        _buildNotesList(),
                        const SizedBox(height: 24),
                      ],

                      // Flashcards list
                      _buildFlashcardsList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... existing methods (_showEditDialog, _showMoreOptions, _buildHeader, etc.)

  // ... existing methods (_buildFlashcardsList, _buildFlashcardItem) but ensure _buildFlashcardsList is NOT inside _buildNotesList
  // Assuming replacment content context.

  // Re-declare _buildFlashcardsList for context if needed, or rely on existing.
  // I will just append _buildNotesList before the class end or wherever appropriate.
  // Better to target the whole file structure or large chunks to be safe.
  // I will use specific StartLine/EndLine from view_file output.

  void _showEditDialog() {
    final titleController = TextEditingController(text: _title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: StudyBuddyColors.cardBackground,
        title: const Text(
          'Edit Study Set',
          style: TextStyle(color: StudyBuddyColors.textPrimary),
        ),
        content: TextField(
          controller: titleController,
          style: const TextStyle(color: StudyBuddyColors.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Title',
            labelStyle: TextStyle(color: StudyBuddyColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _title = titleController.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: StudyBuddyColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.share_rounded,
                color: StudyBuddyColors.textPrimary,
              ),
              title: const Text(
                'Share',
                style: TextStyle(color: StudyBuddyColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.copy_rounded,
                color: StudyBuddyColors.textPrimary,
              ),
              title: const Text(
                'Duplicate',
                style: TextStyle(color: StudyBuddyColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Study set duplicated!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_rounded,
                color: StudyBuddyColors.error,
              ),
              title: const Text(
                'Delete',
                style: TextStyle(color: StudyBuddyColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: StudyBuddyColors.cardBackground,
        title: const Text(
          'Delete Study Set?',
          style: TextStyle(color: StudyBuddyColors.textPrimary),
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: StudyBuddyColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to library
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Study set deleted')),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: StudyBuddyColors.error),
            ),
          ),
        ],
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
          const Spacer(),
          IconButton(
            onPressed: () => _showEditDialog(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: StudyBuddyColors.cardBackground,
                borderRadius: StudyBuddyDecorations.borderRadiusS,
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: StudyBuddyColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _showMoreOptions(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: StudyBuddyColors.cardBackground,
                borderRadius: StudyBuddyDecorations.borderRadiusS,
              ),
              child: const Icon(
                Icons.more_vert_rounded,
                color: StudyBuddyColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            StudyBuddyColors.primary.withValues(alpha: 0.2),
            StudyBuddyColors.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: StudyBuddyDecorations.borderRadiusL,
        border: Border.all(
          color: StudyBuddyColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: StudyBuddyColors.primary.withValues(alpha: 0.2),
                  borderRadius: StudyBuddyDecorations.borderRadiusFull,
                ),
                child: Text(
                  _category,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: StudyBuddyColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: StudyBuddyColors.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: StudyBuddyColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_flashcards.length} flashcards • Created today',
            style: const TextStyle(
              fontSize: 14,
              color: StudyBuddyColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    // Progress includes both mastered and partial learning progress
    // Each mastered card = 100%, each learning card = 50% (partial credit)
    final totalProgress = _flashcards.isNotEmpty
        ? (_masteredCount + (_learningCount * 0.5)) / _flashcards.length
        : 0.0;
    final displayProgress = totalProgress.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        borderRadius: StudyBuddyDecorations.borderRadiusL,
        border: Border.all(color: StudyBuddyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.trending_up_rounded,
                size: 20,
                color: StudyBuddyColors.success,
              ),
              const SizedBox(width: 8),
              const Text(
                'Your Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: StudyBuddyColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${(displayProgress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: StudyBuddyColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: StudyBuddyDecorations.borderRadiusFull,
            child: LinearProgressIndicator(
              value: displayProgress,
              minHeight: 8,
              backgroundColor: StudyBuddyColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                StudyBuddyColors.success,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressStat(
                '$_masteredCount',
                'Mastered',
                StudyBuddyColors.success,
              ),
              _buildProgressStat(
                '$_learningCount',
                'Learning',
                StudyBuddyColors.warning,
              ),
              _buildProgressStat(
                '${_flashcards.length}',
                'Total',
                StudyBuddyColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: StudyBuddyColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.play_arrow_rounded,
            label: 'Study',
            color: StudyBuddyColors.primary,
            onTap: () async {
              await Navigator.pushNamed(
                context,
                AppRoutes.flashcardStudy,
                arguments: {'studySetId': widget.studySetId, 'title': _title},
              );
              // Refresh progress after returning from study session
              _loadFlashcards();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.quiz_rounded,
            label: 'Quiz',
            color: StudyBuddyColors.secondary,
            onTap: () async {
              await Navigator.pushNamed(
                context,
                AppRoutes.quizSetup,
                arguments: {'studySetId': widget.studySetId, 'topic': _title},
              );
              // Refresh progress after returning from quiz
              _loadFlashcards();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.shuffle_rounded,
            label: 'Shuffle',
            color: StudyBuddyColors.warning,
            onTap: () async {
              await Navigator.pushNamed(
                context,
                AppRoutes.flashcardStudy,
                arguments: {
                  'studySetId': widget.studySetId,
                  'title': _title,
                  'shuffle': true,
                },
              );
              // Refresh progress after returning from study session
              _loadFlashcards();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: StudyBuddyDecorations.borderRadiusL,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashcardsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Flashcards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: StudyBuddyColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.addFlashcards,
                  arguments: {
                    'studySetId': widget.studySetId,
                    'studySetTitle': _title,
                    'studySetCategory': _category,
                  },
                );
              },
              icon: const Icon(
                Icons.add_rounded,
                size: 18,
                color: StudyBuddyColors.primary,
              ),
              label: const Text(
                'Add',
                style: TextStyle(
                  color: StudyBuddyColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(
          _flashcards.length,
          (index) => _buildFlashcardItem(index, _flashcards[index])
              .animate()
              .fadeIn(delay: (300 + index * 50).ms)
              .slideX(begin: 0.1, end: 0),
        ),
      ],
    );
  }

  Widget _buildFlashcardItem(int index, Flashcard card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        borderRadius: StudyBuddyDecorations.borderRadiusL,
        border: Border.all(color: StudyBuddyColors.border),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: StudyBuddyDecorations.borderRadiusL,
        ),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: StudyBuddyColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: StudyBuddyColors.primary,
              ),
            ),
          ),
        ),
        title: Text(
          card.term,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: StudyBuddyColors.textPrimary,
          ),
        ),
        subtitle: null,
        iconColor: StudyBuddyColors.textSecondary,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: StudyBuddyColors.background.withValues(alpha: 0.5),
              borderRadius: StudyBuddyDecorations.borderRadiusM,
            ),
            child: Text(
              card.definition,
              style: const TextStyle(
                fontSize: 14,
                color: StudyBuddyColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Linked Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: StudyBuddyColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.noteEditor,
                  // note: Pass arguments if NoteEditor supports pre-filling studySetId
                );
              },
              icon: const Icon(
                Icons.add_rounded,
                size: 18,
                color: StudyBuddyColors.primary,
              ),
              label: const Text(
                'Add Note',
                style: TextStyle(
                  color: StudyBuddyColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_notes.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: StudyBuddyColors.cardBackground,
              borderRadius: StudyBuddyDecorations.borderRadiusM,
              border: Border.all(
                color: StudyBuddyColors.border,
                style: BorderStyle.solid,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.note_alt_outlined,
                  color: StudyBuddyColors.textTertiary,
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  'No notes linked yet',
                  style: TextStyle(color: StudyBuddyColors.textSecondary),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to note detail or editor
                    Navigator.pushNamed(
                      context,
                      AppRoutes.noteEditor,
                      arguments: note,
                    );
                  },
                  child: Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(
                          note.color.startsWith('0x')
                              ? note.color
                              : '0xFF${note.color.replaceAll('#', '')}',
                        ),
                      ),
                      borderRadius: StudyBuddyDecorations.borderRadiusM,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors
                                .white, // Notes usually have colored backgrounds, so white text is safer or need contrast check
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            note.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDate(note.createdAt),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

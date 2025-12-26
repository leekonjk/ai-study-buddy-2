/// Notes Screen
/// Create and view study notes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/entities/note.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/notes/notes_viewmodel.dart';
import 'package:studnet_ai_buddy/presentation/widgets/common/lottie_loading.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';

/// Notes list screen.
class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NotesViewModel>(
      create: (_) => getIt<NotesViewModel>()..loadNotes(),
      child: const _NotesContent(),
    );
  }
}

class _NotesContent extends StatelessWidget {
  const _NotesContent();

  @override
  Widget build(BuildContext context) {
    // Watch the ViewModel state
    final viewModel = context.watch<NotesViewModel>();
    final state = viewModel.state;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: StudyBuddyColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Error banner
              if (state.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: StudyBuddyColors.error,
                  width: double.infinity,
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),

              // Filters
              _buildFilters(context, state),

              // Notes list
              Expanded(
                child: state.viewState == ViewState.loading
                    ? const Center(
                        child: LottieLoading(
                          size: 100,
                          message: "Loading notes...",
                        ),
                      )
                    : (state.filteredNotes.isEmpty
                          ? _buildEmptyState()
                          : _buildNotesList(state.filteredNotes)),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateNoteSheet(context),
        heroTag: 'notes_fab',
        backgroundColor: StudyBuddyColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
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
          const Expanded(
            child: Text(
              'My Notes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: StudyBuddyColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // Search notes logic could be added here
            },
            icon: const Icon(
              Icons.search_rounded,
              color: StudyBuddyColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildFilters(BuildContext context, NotesState state) {
    // Only show filters if we have distinct subjects (plus 'All')
    final subjects = ['All', ...state.subjects];
    if (subjects.length <= 1) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: subjects.map((subject) {
          int count;
          if (subject == 'All') {
            count = state.notes.length;
          } else {
            count = state.notes.where((n) => n.subject == subject).length;
          }
          return _buildFilterChip(
            context,
            subject,
            count,
            state.selectedFilter,
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    int count,
    String selectedFilter,
  ) {
    final isSelected = selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => context.read<NotesViewModel>().setFilter(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? StudyBuddyColors.primary.withValues(alpha: 0.2)
                : StudyBuddyColors.cardBackground,
            borderRadius: StudyBuddyDecorations.borderRadiusFull,
            border: Border.all(
              color: isSelected
                  ? StudyBuddyColors.primary
                  : StudyBuddyColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? StudyBuddyColors.primary
                      : StudyBuddyColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? StudyBuddyColors.primary.withValues(alpha: 0.3)
                      : StudyBuddyColors.border,
                  borderRadius: StudyBuddyDecorations.borderRadiusFull,
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? StudyBuddyColors.primary
                        : StudyBuddyColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 64,
            color: StudyBuddyColors.textTertiary,
          ),
          const SizedBox(height: 16),
          const Text(
            'No notes yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: StudyBuddyColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to create your first note',
            style: TextStyle(
              fontSize: 14,
              color: StudyBuddyColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(List<Note> notes) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return _buildNoteCard(
          context,
          notes[index],
        ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note) {
    final noteColor = _parseColor(note.color);

    return GestureDetector(
      onTap: () => _showNoteDetail(context, note, noteColor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: StudyBuddyColors.cardBackground,
          borderRadius: StudyBuddyDecorations.borderRadiusL,
          border: Border.all(color: StudyBuddyColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: noteColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: noteColor.withValues(alpha: 0.1),
                          borderRadius: StudyBuddyDecorations.borderRadiusFull,
                        ),
                        child: Text(
                          note.subject,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: noteColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(note.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: StudyBuddyColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: StudyBuddyColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note.content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: StudyBuddyColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String colorHex) {
    // If it's a numeric hex string like '0xFF...'
    if (colorHex.startsWith('0x')) {
      return Color(int.parse(colorHex));
    }
    // If it's pure hex 'AABBCC' or '#AABBCC'
    var hex = colorHex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    if (hex.length == 8) {
      return Color(int.parse('0x$hex'));
    }
    // Fallback
    return Colors.blue;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showNoteDetail(BuildContext context, Note note, Color noteColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: StudyBuddyColors.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: StudyBuddyColors.border,
                  borderRadius: StudyBuddyDecorations.borderRadiusFull,
                ),
              ),
              // Color bar
              Container(height: 4, color: noteColor),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
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
                              color: noteColor.withValues(alpha: 0.1),
                              borderRadius:
                                  StudyBuddyDecorations.borderRadiusFull,
                            ),
                            child: Text(
                              note.subject,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: noteColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              // Delete note logic
                              context.read<NotesViewModel>().deleteNote(
                                note.id,
                              );
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: StudyBuddyColors.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        note.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: StudyBuddyColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(note.createdAt),
                        style: const TextStyle(
                          fontSize: 13,
                          color: StudyBuddyColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        note.content,
                        style: const TextStyle(
                          fontSize: 16,
                          color: StudyBuddyColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
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

  void _showCreateNoteSheet(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedSubject = 'General';
    Color selectedColor = Colors.blue;

    final subjects = [
      'General',
      'Biology',
      'Mathematics',
      'Physics',
      'Computer Science',
      'Chemistry',
      'History',
    ];
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: StudyBuddyColors.cardBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: StudyBuddyColors.border,
                      borderRadius: StudyBuddyDecorations.borderRadiusFull,
                    ),
                  ),
                ),
                // Color bar
                Container(height: 4, color: selectedColor),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create Note',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: StudyBuddyColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Subject dropdown
                      DropdownButtonFormField<String>(
                        initialValue: selectedSubject,
                        decoration: InputDecoration(
                          labelText: 'Subject',
                          labelStyle: const TextStyle(
                            color: StudyBuddyColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: StudyBuddyColors.background,
                          border: OutlineInputBorder(
                            borderRadius: StudyBuddyDecorations.borderRadiusM,
                            borderSide: const BorderSide(
                              color: StudyBuddyColors.border,
                            ),
                          ),
                        ),
                        dropdownColor: StudyBuddyColors.cardBackground,
                        style: const TextStyle(
                          color: StudyBuddyColors.textPrimary,
                        ),
                        items: subjects
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setSheetState(() => selectedSubject = v!),
                      ),
                      const SizedBox(height: 16),

                      // Color picker
                      const Text(
                        'Color',
                        style: TextStyle(
                          fontSize: 14,
                          color: StudyBuddyColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: colors
                            .map(
                              (c) => GestureDetector(
                                onTap: () =>
                                    setSheetState(() => selectedColor = c),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: selectedColor == c
                                        ? Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      TextField(
                        controller: titleController,
                        style: const TextStyle(
                          color: StudyBuddyColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: const TextStyle(
                            color: StudyBuddyColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: StudyBuddyColors.background,
                          border: OutlineInputBorder(
                            borderRadius: StudyBuddyDecorations.borderRadiusM,
                            borderSide: const BorderSide(
                              color: StudyBuddyColors.border,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Content
                      TextField(
                        controller: contentController,
                        style: const TextStyle(
                          color: StudyBuddyColors.textPrimary,
                        ),
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Content',
                          labelStyle: const TextStyle(
                            color: StudyBuddyColors.textSecondary,
                          ),
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: StudyBuddyColors.background,
                          border: OutlineInputBorder(
                            borderRadius: StudyBuddyDecorations.borderRadiusM,
                            borderSide: const BorderSide(
                              color: StudyBuddyColors.border,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleController.text.isNotEmpty) {
                              // Convert Color to Hex String
                              // Using component accessors as .value is deprecated
                              final int colorValue =
                                  (selectedColor.a.toInt() << 24) |
                                  (selectedColor.r.toInt() << 16) |
                                  (selectedColor.g.toInt() << 8) |
                                  selectedColor.b.toInt();
                              final colorHex =
                                  '0x${colorValue.toRadixString(16).toUpperCase()}';

                              context.read<NotesViewModel>().createNote(
                                title: titleController.text,
                                content: contentController.text,
                                subject: selectedSubject,
                                colorHex: colorHex,
                              );

                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Note created'),
                                  backgroundColor: StudyBuddyColors.success,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: StudyBuddyColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  StudyBuddyDecorations.borderRadiusFull,
                            ),
                          ),
                          child: const Text(
                            'Save Note',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

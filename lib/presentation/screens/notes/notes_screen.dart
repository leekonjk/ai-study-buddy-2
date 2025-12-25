/// Notes Screen
/// Create and view study notes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';

/// Demo note data.
class NoteData {
  final String id;
  final String title;
  final String content;
  final String subject;
  final DateTime createdAt;
  final Color color;

  const NoteData({
    required this.id,
    required this.title,
    required this.content,
    required this.subject,
    required this.createdAt,
    required this.color,
  });
}

/// Notes list screen.
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _selectedFilter = 'All';

  final List<NoteData> _notes = [
    NoteData(
      id: '1',
      title: 'Photosynthesis Process',
      content:
          'Light-dependent reactions occur in thylakoid membranes. Light energy converts water and CO2 into glucose and oxygen. Key factors: chlorophyll, sunlight intensity, CO2 concentration.',
      subject: 'Biology',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      color: Colors.green,
    ),
    NoteData(
      id: '2',
      title: 'Quadratic Formula',
      content:
          'x = (-b ± √(b²-4ac)) / 2a\n\nUsed to solve ax² + bx + c = 0\nDiscriminant (b²-4ac) determines number of solutions',
      subject: 'Mathematics',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      color: Colors.blue,
    ),
    NoteData(
      id: '3',
      title: 'Newton\'s Laws of Motion',
      content:
          '1st Law: Object at rest stays at rest\n2nd Law: F = ma\n3rd Law: Every action has equal and opposite reaction',
      subject: 'Physics',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      color: Colors.orange,
    ),
    NoteData(
      id: '4',
      title: 'Data Structures Overview',
      content:
          'Arrays: O(1) access, O(n) insert\nLinked Lists: O(n) access, O(1) insert\nHash Tables: O(1) average for all operations',
      subject: 'Computer Science',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      color: Colors.purple,
    ),
  ];

  List<NoteData> get _filteredNotes {
    if (_selectedFilter == 'All') return _notes;
    return _notes.where((n) => n.subject == _selectedFilter).toList();
  }

  List<String> get _subjects => _notes.map((n) => n.subject).toSet().toList();

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

              // Filters
              _buildFilters(),

              // Notes list
              Expanded(
                child: _filteredNotes.isEmpty
                    ? _buildEmptyState()
                    : _buildNotesList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateNoteSheet(),
        backgroundColor: StudyBuddyColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
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
              // Search notes
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

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildFilterChip('All', _notes.length),
          ..._subjects.map(
            (subject) => _buildFilterChip(
              subject,
              _notes.where((n) => n.subject == subject).length,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = label),
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

  Widget _buildNotesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _filteredNotes.length,
      itemBuilder: (context, index) {
        return _buildNoteCard(
          _filteredNotes[index],
        ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildNoteCard(NoteData note) {
    return GestureDetector(
      onTap: () => _showNoteDetail(note),
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
                color: note.color,
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
                          color: note.color.withValues(alpha: 0.1),
                          borderRadius: StudyBuddyDecorations.borderRadiusFull,
                        ),
                        child: Text(
                          note.subject,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: note.color,
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

  void _showNoteDetail(NoteData note) {
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
              Container(height: 4, color: note.color),
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
                              color: note.color.withValues(alpha: 0.1),
                              borderRadius:
                                  StudyBuddyDecorations.borderRadiusFull,
                            ),
                            child: Text(
                              note.subject,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: note.color,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              // Edit note
                            },
                            icon: const Icon(
                              Icons.edit_rounded,
                              color: StudyBuddyColors.textSecondary,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Delete note
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

  void _showCreateNoteSheet() {
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
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
                              // Create new note and add to list
                              final newNote = NoteData(
                                id: DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                title: titleController.text,
                                content: contentController.text,
                                subject: selectedSubject,
                                createdAt: DateTime.now(),
                                color: selectedColor,
                              );
                              setState(() {
                                _notes.insert(0, newNote);
                              });
                              Navigator.pop(context);
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

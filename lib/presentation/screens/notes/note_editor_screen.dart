import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:studnet_ai_buddy/domain/entities/note.dart';
import 'package:studnet_ai_buddy/domain/repositories/note_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/study_set_repository.dart';
import 'package:studnet_ai_buddy/domain/entities/study_set.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/widgets/common/loading_indicator.dart'; // If loading used
import 'package:studnet_ai_buddy/presentation/widgets/core/gradient_scaffold.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String _selectedSubject = 'General';
  Color _selectedColor = Colors.blue;
  String? _selectedStudySetId;
  bool _isLoading = false;

  final List<String> _subjects = [
    'General',
    'Mathematics',
    'Science',
    'History',
    'Literature',
    'Computer Science',
    'Languages',
    'Arts',
    'Other',
  ];

  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _loadStudySets();

    if (widget.note != null) {
      _selectedSubject = widget.note!.subject;
      _selectedColor = _parseColor(widget.note!.color);
      _selectedStudySetId = widget.note!.studySetId;
    }
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('0x')) {
        return Color(int.parse(colorString));
      } else if (colorString.startsWith('#')) {
        return Color(int.parse('0xFF${colorString.substring(1)}'));
      }
      return Colors.blue;
    } catch (e) {
      return Colors.blue;
    }
  }

  String _colorToHex(Color color) {
    return '0xFF${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  List<StudySet> _studySets = [];

  final _noteRepository = GetIt.I<NoteRepository>();
  final _studySetRepository = GetIt.I<StudySetRepository>();

  // ... existing lists (_subjects, _colors)

  Future<void> _loadStudySets() async {
    final result = await _studySetRepository.getAllStudySets();
    if (mounted) {
      result.fold(
        onSuccess: (sets) {
          setState(() {
            _studySets = sets;
          });
        },
        onFailure: (f) {
          debugPrint('Failed to load study sets: ${f.message}');
        },
      );
    }
  }

  // ... existing helper methods (_parseColor, _colorToHex)

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final colorHex = _colorToHex(_selectedColor);

      if (widget.note == null) {
        // Create
        await _noteRepository.createNote(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          subject: _selectedSubject,
          colorHex: colorHex,
          studySetId: _selectedStudySetId,
        );
      } else {
        // Update
        final note = widget.note!.copyWith(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          subject: _selectedSubject,
          color: colorHex,
          studySetId: _selectedStudySetId,
        );
        await _noteRepository.updateNote(note);
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate refresh needed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save note: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
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
                  const SizedBox(width: 16),
                  Text(
                    widget.note == null ? 'Create Note' : 'Edit Note',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: StudyBuddyColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (_isLoading)
                    const Center(child: LoadingIndicator(size: 24))
                  else
                    IconButton(
                      onPressed: _saveNote,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: StudyBuddyColors.primary,
                          borderRadius: StudyBuddyDecorations.borderRadiusS,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedSubject,
                      dropdownColor: StudyBuddyColors.cardBackground,
                      style: const TextStyle(
                        color: StudyBuddyColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        labelStyle: TextStyle(
                          color: StudyBuddyColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: StudyBuddyColors.cardBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(
                            color: StudyBuddyColors.border,
                          ),
                        ),
                      ),
                      items: _subjects
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedSubject = v!),
                    ),
                    const SizedBox(height: 16),

                    // Study Set Dropdown
                    if (_studySets.isNotEmpty) ...[
                      DropdownButtonFormField<String?>(
                        value: _selectedStudySetId,
                        dropdownColor: StudyBuddyColors.cardBackground,
                        style: const TextStyle(
                          color: StudyBuddyColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Link to Study Set (Optional)',
                          labelStyle: TextStyle(
                            color: StudyBuddyColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: StudyBuddyColors.cardBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide(
                              color: StudyBuddyColors.border,
                            ),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('None'),
                          ),
                          ..._studySets.map((set) {
                            return DropdownMenuItem<String?>(
                              value: set.id,
                              child: Text(
                                set.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }),
                        ],
                        onChanged: (v) =>
                            setState(() => _selectedStudySetId = v),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Color Picker
                    Row(
                      children: _colors
                          .map(
                            (c) => GestureDetector(
                              onTap: () => setState(() => _selectedColor = c),
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: _selectedColor == c
                                      ? Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        )
                                      : null,
                                  boxShadow: [
                                    if (_selectedColor == c)
                                      BoxShadow(
                                        color: c.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    // ... existing text fields

                    // Title Input
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: StudyBuddyColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Note Title',
                        hintStyle: TextStyle(
                          color: StudyBuddyColors.textTertiary,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(color: StudyBuddyColors.border),

                    // Content Input
                    TextField(
                      controller: _contentController,
                      style: const TextStyle(
                        fontSize: 16,
                        color: StudyBuddyColors.textSecondary,
                        height: 1.5,
                      ),
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Start typing your note here...',
                        hintStyle: TextStyle(
                          color: StudyBuddyColors.textTertiary,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

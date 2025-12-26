import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/domain/entities/subject.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';

class SubjectDialog extends StatefulWidget {
  final Subject? subject;

  const SubjectDialog({super.key, this.subject});

  @override
  State<SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<SubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late String _selectedColorHex;

  final List<String> _colors = [
    '#4A90E2', // Blue
    '#50C878', // Emerald
    '#FF6B6B', // Red
    '#FFB400', // Orange
    '#9B59B6', // Purple
    '#1ABC9C', // Teal
    '#E91E63', // Pink
    '#00BCD4', // Cyan
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject?.name ?? '');
    _codeController = TextEditingController(text: widget.subject?.code ?? '');
    _selectedColorHex = widget.subject?.colorHex ?? _colors[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: StudyBuddyColors.cardBackground,
      title: Text(
        widget.subject == null ? 'Add Subject' : 'Edit Subject',
        style: const TextStyle(color: StudyBuddyColors.textPrimary),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: StudyBuddyColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  hintText: 'e.g. Mathematics',
                  labelStyle: TextStyle(color: StudyBuddyColors.textSecondary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: StudyBuddyColors.border),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                style: const TextStyle(color: StudyBuddyColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Subject Code (Optional)',
                  hintText: 'e.g. MATH-101',
                  labelStyle: TextStyle(color: StudyBuddyColors.textSecondary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: StudyBuddyColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Color Code',
                style: TextStyle(
                  color: StudyBuddyColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colors.map((colorHex) {
                  final isSelected = _selectedColorHex == colorHex;
                  final color = Color(
                    int.parse(colorHex.replaceAll('#', '0xFF')),
                  );

                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorHex = colorHex),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: StudyBuddyColors.textPrimary,
                                width: 3,
                              )
                            : null,
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: StudyBuddyColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newSubject = Subject(
        id:
            widget.subject?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        colorHex: _selectedColorHex,
        creditHours: widget.subject?.creditHours ?? 3,
        difficulty:
            widget.subject?.difficulty ?? SubjectDifficulty.intermediate,
        topicIds: widget.subject?.topicIds ?? [],
      );
      Navigator.pop(context, newSubject);
    }
  }
}

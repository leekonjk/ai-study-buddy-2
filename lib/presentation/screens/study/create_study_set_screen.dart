/// Create Study Set Screen
/// Screen for creating a new study set with title, subject, and description.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';

import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/repositories/academic_repository.dart';
import 'package:studnet_ai_buddy/domain/entities/subject.dart';
import 'package:studnet_ai_buddy/presentation/navigation/app_router.dart';

/// Screen to create a new study set.
class CreateStudySetScreen extends StatefulWidget {
  const CreateStudySetScreen({super.key});

  @override
  State<CreateStudySetScreen> createState() => _CreateStudySetScreenState();
}

class _CreateStudySetScreenState extends State<CreateStudySetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Subject> _enrolledSubjects = [];
  String? _selectedSubjectId;
  bool _isLoadingSubjects = true;

  String _selectedCategory = 'General';
  bool _isPrivate = true;

  final List<String> _categories = [
    'General',
    'Mathematics',
    'Science',
    'Languages',
    'History',
    'Computer Science',
    'Business',
    'Arts',
    'Medicine',
    'Engineering',
    'Other',
  ];

  final List<Color> _categoryColors = [
    StudyBuddyColors.primary,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.red,
    Colors.cyan,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final result = await getIt<AcademicRepository>().getEnrolledSubjects();
    if (mounted) {
      setState(() {
        _enrolledSubjects = result.fold(
          onSuccess: (subjects) => subjects,
          onFailure: (_) => [],
        );
        _isLoadingSubjects = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _proceedToAddFlashcards() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pushNamed(
      AppRoutes.addFlashcards,
      arguments: {
        'studySetTitle': _titleController.text.trim(),
        'studySetCategory': _selectedCategory,
        'studySetDescription': _descriptionController.text.trim(),
        'isPrivate': _isPrivate,
        'subjectId': _selectedSubjectId, // Pass the selected subject ID
      },
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

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title field
                        _buildSectionLabel('Title', Icons.title_rounded),
                        const SizedBox(height: 12),
                        _buildTitleField()
                            .animate()
                            .fadeIn(delay: 100.ms)
                            .slideX(begin: -0.1, end: 0),
                        const SizedBox(height: 24),

                        // Subject selection (New)
                        _buildSectionLabel('Subject', Icons.book_rounded),
                        const SizedBox(height: 12),
                        _buildSubjectSelector()
                            .animate()
                            .fadeIn(delay: 150.ms)
                            .slideX(begin: -0.1, end: 0),
                        const SizedBox(height: 24),

                        // Category selection
                        _buildSectionLabel(
                          'Category (Optional)',
                          Icons.category_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildCategorySelector()
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideX(begin: -0.1, end: 0),
                        const SizedBox(height: 24),

                        // Description field
                        _buildSectionLabel(
                          'Description (Optional)',
                          Icons.description_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildDescriptionField()
                            .animate()
                            .fadeIn(delay: 300.ms)
                            .slideX(begin: -0.1, end: 0),
                        const SizedBox(height: 24),

                        // Privacy toggle
                        _buildPrivacyToggle()
                            .animate()
                            .fadeIn(delay: 400.ms)
                            .slideX(begin: -0.1, end: 0),
                        const SizedBox(height: 32),

                        // Preview card
                        _buildPreviewCard()
                            .animate()
                            .fadeIn(delay: 500.ms)
                            .scale(begin: const Offset(0.95, 0.95)),
                      ],
                    ),
                  ),
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
          const Expanded(
            child: Text(
              'Create Study Set',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: StudyBuddyColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: StudyBuddyColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: StudyBuddyColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        borderRadius: StudyBuddyDecorations.borderRadiusL,
        border: Border.all(color: StudyBuddyColors.border),
      ),
      child: TextFormField(
        controller: _titleController,
        style: const TextStyle(
          color: StudyBuddyColors.textPrimary,
          fontSize: 16,
        ),
        decoration: const InputDecoration(
          hintText: 'Enter study set title...',
          hintStyle: TextStyle(color: StudyBuddyColors.textTertiary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a title';
          }
          if (value.trim().length < 3) {
            return 'Title must be at least 3 characters';
          }
          return null;
        },
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildSubjectSelector() {
    if (_isLoadingSubjects) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_enrolledSubjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: StudyBuddyColors.cardBackground,
          borderRadius: StudyBuddyDecorations.borderRadiusM,
          border: Border.all(color: StudyBuddyColors.border),
        ),
        child: const Text(
          'No enrolled subjects found. Check your profile.',
          style: TextStyle(color: StudyBuddyColors.textSecondary),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        borderRadius: StudyBuddyDecorations.borderRadiusL,
        border: Border.all(color: StudyBuddyColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSubjectId,
          hint: const Text(
            'Select a Subject',
            style: TextStyle(color: StudyBuddyColors.textTertiary),
          ),
          isExpanded: true,
          dropdownColor: StudyBuddyColors.cardBackground,
          icon: const Icon(
            Icons.arrow_drop_down_rounded,
            color: StudyBuddyColors.primary,
          ),
          items: _enrolledSubjects.map((subject) {
            return DropdownMenuItem<String>(
              value: subject.id,
              child: Text(
                subject.name,
                style: const TextStyle(
                  color: StudyBuddyColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSubjectId = value;
              // Auto-select category if possible or relevant
            });
          },
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          final color = _categoryColors[index];

          return Padding(
            padding: EdgeInsets.only(right: 8, left: index == 0 ? 0 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.2)
                      : StudyBuddyColors.cardBackground,
                  borderRadius: StudyBuddyDecorations.borderRadiusFull,
                  border: Border.all(
                    color: isSelected ? color : StudyBuddyColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? color
                          : StudyBuddyColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        borderRadius: StudyBuddyDecorations.borderRadiusL,
        border: Border.all(color: StudyBuddyColors.border),
      ),
      child: TextFormField(
        controller: _descriptionController,
        style: const TextStyle(
          color: StudyBuddyColors.textPrimary,
          fontSize: 16,
        ),
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Add a description for your study set...',
          hintStyle: TextStyle(color: StudyBuddyColors.textTertiary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildPrivacyToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        borderRadius: StudyBuddyDecorations.borderRadiusL,
        border: Border.all(color: StudyBuddyColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: StudyBuddyColors.primary.withValues(alpha: 0.1),
              borderRadius: StudyBuddyDecorations.borderRadiusS,
            ),
            child: Icon(
              _isPrivate ? Icons.lock_rounded : Icons.public_rounded,
              color: StudyBuddyColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isPrivate ? 'Private' : 'Public',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: StudyBuddyColors.textPrimary,
                  ),
                ),
                Text(
                  _isPrivate
                      ? 'Only you can see this study set'
                      : 'Anyone can discover and use this set',
                  style: const TextStyle(
                    fontSize: 12,
                    color: StudyBuddyColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isPrivate,
            onChanged: (value) => setState(() => _isPrivate = value),
            activeThumbColor: StudyBuddyColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final categoryIndex = _categories.indexOf(_selectedCategory);
    final color = _categoryColors[categoryIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: StudyBuddyColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: StudyBuddyDecorations.borderRadiusL,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
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
                      color: color.withValues(alpha: 0.2),
                      borderRadius: StudyBuddyDecorations.borderRadiusFull,
                    ),
                    child: Text(
                      _selectedCategory,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isPrivate ? Icons.lock_rounded : Icons.public_rounded,
                    size: 16,
                    color: StudyBuddyColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title.isNotEmpty ? title : 'Your Study Set Title',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: StudyBuddyColors.textPrimary,
                ),
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: StudyBuddyColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildPreviewStat(Icons.style_rounded, '0 cards'),
                  const SizedBox(width: 16),
                  _buildPreviewStat(Icons.access_time_rounded, 'Just now'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewStat(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: StudyBuddyColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: StudyBuddyColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    final isValid = _titleController.text.trim().length >= 3;

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
            onPressed: isValid ? _proceedToAddFlashcards : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: StudyBuddyColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: StudyBuddyColors.primary.withValues(
                alpha: 0.3,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: StudyBuddyDecorations.borderRadiusFull,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Add Flashcards',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

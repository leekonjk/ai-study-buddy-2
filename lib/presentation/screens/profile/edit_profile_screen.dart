import 'package:flutter/material.dart';

import 'package:studnet_ai_buddy/di/service_locator.dart';

import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';

import 'package:studnet_ai_buddy/presentation/widgets/common/loading_indicator.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/profile/profile_viewmodel.dart'; // Ensure VM exists
import 'package:studnet_ai_buddy/presentation/widgets/core/gradient_scaffold.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final ProfileViewModel _viewModel;
  late TextEditingController _nameController;
  late TextEditingController _universityController;
  late TextEditingController _semesterController;
  late TextEditingController _weakAreaController; // For adding new tags
  late TextEditingController _goalController; // For adding new tags

  List<String> _weakAreas = [];
  List<String> _goals = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ProfileViewModel>();

    _nameController = TextEditingController();
    _universityController = TextEditingController();
    _semesterController = TextEditingController();
    _weakAreaController = TextEditingController();
    _goalController = TextEditingController();

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    // Ensure profile is loaded if not already
    if (_viewModel.state.academicProfile == null) {
      await _viewModel.loadProfile();
    }

    final state = _viewModel.state;

    if (!mounted) return;

    setState(() {
      _nameController.text = state.displayName;
      if (state.academicProfile != null) {
        _universityController.text = state.academicProfile!.universityName;
        _semesterController.text = state.academicProfile!.currentSemester
            .toString();
        _weakAreas = List.from(state.academicProfile!.weakAreas);
        _goals = List.from(state.academicProfile!.goals);
      }
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _universityController.dispose();
    _semesterController.dispose();
    _weakAreaController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _save() async {
    setState(() => _isLoading = true);

    final currentProfile = _viewModel.state.academicProfile;

    if (currentProfile != null) {
      final updatedProfile = currentProfile.copyWith(
        studentName: _nameController.text,
        universityName: _universityController.text,
        currentSemester: int.tryParse(_semesterController.text) ?? 1,
        weakAreas: _weakAreas,
        goals: _goals,
      );

      await _viewModel.updateProfile(updatedProfile);

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error: Profile not loaded. Cannot save."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Basic Info'),
                  _buildTextField('Full Name', _nameController),
                  const SizedBox(height: 16),
                  _buildTextField('University', _universityController),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Semester',
                    _semesterController,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 32),
                  _buildSectionTitle('AI Personalization'),
                  const Text(
                    'Help the AI customize your study plan by telling us your weak areas and goals.',
                    style: TextStyle(
                      color: StudyBuddyColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTagInput(
                    'Weak Areas',
                    _weakAreas,
                    _weakAreaController,
                    (val) {
                      setState(() => _weakAreas.add(val));
                    },
                  ),

                  const SizedBox(height: 24),
                  _buildTagInput('Academic Goals', _goals, _goalController, (
                    val,
                  ) {
                    setState(() => _goals.add(val));
                  }),

                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StudyBuddyColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: StudyBuddyColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: StudyBuddyColors.cardBackground,
      ),
    );
  }

  Widget _buildTagInput(
    String label,
    List<String> tags,
    TextEditingController controller,
    Function(String) onAdd,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: StudyBuddyColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: tags
              .map(
                (tag) => Chip(
                  label: Text(tag),
                  onDeleted: () => setState(() => tags.remove(tag)),
                  backgroundColor: StudyBuddyColors.primary.withValues(
                    alpha: 0.1,
                  ),
                  labelStyle: const TextStyle(color: StudyBuddyColors.primary),
                  deleteIconColor: StudyBuddyColors.primary,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Add new...',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: StudyBuddyColors.cardBackground,
                ),
                onSubmitted: (val) {
                  if (val.isNotEmpty) {
                    onAdd(val);
                    controller.clear();
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.add_circle,
                color: StudyBuddyColors.primary,
              ),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  onAdd(controller.text);
                  controller.clear();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

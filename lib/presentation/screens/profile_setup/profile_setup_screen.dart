/// Profile Setup Screen
/// Initial profile setup for new users.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/entities/academic_profile.dart';
import 'package:studnet_ai_buddy/domain/repositories/academic_repository.dart';
import 'package:studnet_ai_buddy/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/gradient_scaffold.dart';

/// Profile setup screen for collecting user information.
class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _universityController = TextEditingController();
  final _majorController = TextEditingController();
  String _selectedLevel = 'Undergraduate';
  bool _isLoading = false;

  final List<String> _levels = [
    'High School',
    'Undergraduate',
    'Graduate',
    'PhD',
    'Professional',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final profile = AcademicProfile(
      id: '', // Will be set by repository
      studentName: _nameController.text.trim(),
      programName: _majorController.text.trim(),
      currentSemester: 1,
      enrolledSubjectIds: [],
      enrollmentDate: DateTime.now(),
    );

    final result = await getIt<AcademicRepository>().saveAcademicProfile(profile);
    
    result.fold(
      onSuccess: (_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      },
      onFailure: (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        }
      },
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  
                  // Title
                  const Text(
                    'Set Up Your Profile',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: StudyBuddyColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Help us personalize your learning experience',
                    style: TextStyle(
                      fontSize: 16,
                      color: StudyBuddyColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name field
                  const Text(
                    'Your Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: StudyBuddyColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: StudyBuddyColors.textPrimary),
                    decoration: StudyBuddyDecorations.inputDecoration(
                      hintText: 'Enter your name',
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                        color: StudyBuddyColors.textSecondary,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // University field
                  const Text(
                    'University/Institution',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: StudyBuddyColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _universityController,
                    style: const TextStyle(color: StudyBuddyColors.textPrimary),
                    decoration: StudyBuddyDecorations.inputDecoration(
                      hintText: 'Enter your university',
                      prefixIcon: const Icon(
                        Icons.school_outlined,
                        color: StudyBuddyColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Major field
                  const Text(
                    'Major/Program',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: StudyBuddyColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _majorController,
                    style: const TextStyle(color: StudyBuddyColors.textPrimary),
                    decoration: StudyBuddyDecorations.inputDecoration(
                      hintText: 'Enter your major',
                      prefixIcon: const Icon(
                        Icons.menu_book_outlined,
                        color: StudyBuddyColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Level dropdown
                  const Text(
                    'Education Level',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: StudyBuddyColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: StudyBuddyColors.cardBackground,
                      borderRadius: StudyBuddyDecorations.borderRadiusFull,
                      border: Border.all(color: StudyBuddyColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLevel,
                        isExpanded: true,
                        dropdownColor: StudyBuddyColors.cardBackground,
                        style: const TextStyle(
                          color: StudyBuddyColors.textPrimary,
                          fontSize: 16,
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down_rounded,
                          color: StudyBuddyColors.textSecondary,
                        ),
                        items: _levels.map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedLevel = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StudyBuddyColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: StudyBuddyDecorations.borderRadiusFull,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Continue',
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
          ),
        ),
      ),
    );
  }
} 


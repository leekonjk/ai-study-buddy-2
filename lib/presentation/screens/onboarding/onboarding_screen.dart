/// Onboarding Screen.
/// Multi-step onboarding flow for academic profile setup.
/// 
/// Layer: Presentation (UI)
/// Responsibility: Display onboarding steps, collect user input.
/// Binds to: OnboardingViewModel
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/onboarding/onboarding_viewmodel.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OnboardingViewModel>(
      create: (_) => getIt<OnboardingViewModel>()..checkExistingProfile(),
      child: const _OnboardingContent(),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  const _OnboardingContent();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingViewModel>().state;

    // If already completed onboarding, navigate to dashboard
    if (state.isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      });
    }

    return Scaffold(
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Progress indicator
                  _ProgressHeader(
                    currentStep: state.currentStep,
                    totalSteps: state.totalSteps,
                    progress: state.progress,
                  ),

                  // Error message
                  if (state.hasError)
                    _ErrorBanner(
                      message: state.errorMessage!,
                      onDismiss: () => context.read<OnboardingViewModel>().dismissError(),
                    ),

                  // Step content
                  Expanded(
                    child: _StepContent(currentStep: state.currentStep),
                  ),

                  // Navigation buttons
                  _NavigationButtons(
                    isFirstStep: state.isFirstStep,
                    isLastStep: state.isLastStep,
                    canProceed: state.canProceedFromCurrentStep,
                    isLoading: state.isLoading,
                  ),
                ],
              ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double progress;

  const _ProgressHeader({
    required this.currentStep,
    required this.totalSteps,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${currentStep + 1} of $totalSteps',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onDismiss,
            color: Colors.red[700],
          ),
        ],
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  final int currentStep;

  const _StepContent({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: switch (currentStep) {
        0 => const _NameStep(),
        1 => const _ProgramStep(),
        2 => const _SemesterStep(),
        3 => const _SubjectsStep(),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingViewModel>().state;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Let\'s set up your study profile. What should we call you?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),
          TextField(
            onChanged: (value) => context.read<OnboardingViewModel>().setStudentName(value),
            decoration: InputDecoration(
              labelText: 'Your Name',
              hintText: 'Enter your name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            controller: TextEditingController(text: state.studentName)
              ..selection = TextSelection.collapsed(offset: state.studentName.length),
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
    );
  }
}

class _ProgramStep extends StatelessWidget {
  const _ProgramStep();

  static const _programs = [
    'Computer Science',
    'Software Engineering',
    'Information Technology',
    'Data Science',
    'Electrical Engineering',
    'Business Administration',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingViewModel>().state;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Program',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your academic program or field of study.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _programs.length,
              itemBuilder: (context, index) {
                final program = _programs[index];
                final isSelected = state.selectedProgram == program;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    title: Text(program),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                        : null,
                    onTap: () => context.read<OnboardingViewModel>().setProgram(program),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SemesterStep extends StatelessWidget {
  const _SemesterStep();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingViewModel>().state;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Semester',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Which semester are you currently in?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                final semester = index + 1;
                final isSelected = state.selectedSemester == semester;

                return InkWell(
                  onTap: () => context.read<OnboardingViewModel>().setSemester(semester),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey[100],
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Semester $semester',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectsStep extends StatelessWidget {
  const _SubjectsStep();

  static const _availableSubjects = {
    'cs101': 'Introduction to Programming',
    'cs201': 'Data Structures',
    'cs301': 'Algorithms',
    'cs401': 'Database Systems',
    'cs501': 'Operating Systems',
    'cs601': 'Software Engineering',
    'math101': 'Calculus I',
    'math201': 'Linear Algebra',
  };

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingViewModel>().state;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Subjects',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the subjects you\'re currently enrolled in.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.selectedSubjectIds.length} selected',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _availableSubjects.length,
              itemBuilder: (context, index) {
                final entry = _availableSubjects.entries.elementAt(index);
                final subjectId = entry.key;
                final subjectName = entry.value;
                final isSelected = state.selectedSubjectIds.contains(subjectId);

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (_) => context.read<OnboardingViewModel>().toggleSubject(subjectId),
                  title: Text(subjectName),
                  subtitle: Text(subjectId.toUpperCase()),
                  secondary: Icon(
                    isSelected ? Icons.book : Icons.book_outlined,
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationButtons extends StatelessWidget {
  final bool isFirstStep;
  final bool isLastStep;
  final bool canProceed;
  final bool isLoading;

  const _NavigationButtons({
    required this.isFirstStep,
    required this.isLastStep,
    required this.canProceed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isFirstStep)
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.read<OnboardingViewModel>().previousStep(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
          if (!isFirstStep) const SizedBox(width: 16),
          Expanded(
            flex: isFirstStep ? 1 : 1,
            child: ElevatedButton(
              onPressed: canProceed
                  ? () {
                      if (isLastStep) {
                        context.read<OnboardingViewModel>().completeOnboarding();
                      } else {
                        context.read<OnboardingViewModel>().nextStep();
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isLastStep ? 'Complete Setup' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

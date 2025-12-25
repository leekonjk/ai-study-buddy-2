/// Onboarding Flow
/// Multi-step conversational onboarding matching StudySmarter design.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/services/local_storage_service.dart';
import 'package:studnet_ai_buddy/presentation/auth/auth_gate.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/gradient_scaffold.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/progress_indicator_bar.dart';
import 'package:studnet_ai_buddy/presentation/screens/onboarding/steps/welcome_step.dart';
import 'package:studnet_ai_buddy/presentation/screens/onboarding/steps/name_step.dart';
import 'package:studnet_ai_buddy/presentation/screens/onboarding/steps/education_step.dart';
import 'package:studnet_ai_buddy/presentation/screens/onboarding/steps/goals_step.dart';
import 'package:studnet_ai_buddy/presentation/screens/onboarding/steps/upload_step.dart';
import 'package:studnet_ai_buddy/presentation/screens/onboarding/steps/completion_step.dart';

/// Multi-step onboarding flow.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  final Map<String, dynamic> _onboardingData = {};

  final List<Widget> _steps = [
    const WelcomeStep(),
    const NameStep(),
    const EducationStep(),
    const GoalsStep(),
    const UploadStep(),
    const CompletionStep(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    final localStorageService = getIt<LocalStorageService>();
    await localStorageService.setIntroSeen(true);
    await localStorageService.setOnboarded(true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    }
  }

  void _updateData(String key, dynamic value) {
    setState(() {
      _onboardingData[key] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: _currentStep > 0 ? _previousStep : null,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: StudyBuddyColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: ProgressIndicatorBar(
                    progress: (_currentStep + 1) / _steps.length,
                  ),
                ),
              ],
            ),
          ),
          // Steps
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                return OnboardingStepWrapper(
                  step: _steps[index],
                  stepIndex: index,
                  currentStep: _currentStep,
                  onNext: _nextStep,
                  onSkip: _completeOnboarding,
                  onUpdateData: _updateData,
                  data: _onboardingData,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Controller for onboarding steps to access parent callbacks.
class OnboardingStepController extends InheritedWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final Function(String, dynamic) onUpdateData;
  final Map<String, dynamic> data;

  const OnboardingStepController({
    super.key,
    required this.onNext,
    required this.onSkip,
    required this.onUpdateData,
    required this.data,
    required super.child,
  });

  static OnboardingStepController? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<OnboardingStepController>();
  }

  @override
  bool updateShouldNotify(OnboardingStepController oldWidget) {
    return onNext != oldWidget.onNext ||
        onSkip != oldWidget.onSkip ||
        onUpdateData != oldWidget.onUpdateData ||
        data != oldWidget.data;
  }
}

/// Wrapper for onboarding steps with common functionality.
class OnboardingStepWrapper extends StatelessWidget {
  final Widget step;
  final int stepIndex;
  final int currentStep;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final Function(String, dynamic) onUpdateData;
  final Map<String, dynamic> data;

  const OnboardingStepWrapper({
    super.key,
    required this.step,
    required this.stepIndex,
    required this.currentStep,
    required this.onNext,
    required this.onSkip,
    required this.onUpdateData,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingStepController(
      onNext: onNext,
      onSkip: onSkip,
      onUpdateData: onUpdateData,
      data: data,
      child: step,
    );
  }
}


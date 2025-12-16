/// Onboarding ViewModel.
/// Manages state for the onboarding flow.
/// 
/// Layer: Presentation
/// Responsibility: Handle onboarding steps, academic profile creation.
/// Inputs: User input (name, program, semester, subjects).
/// Outputs: Onboarding state, navigation triggers.
library;

import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';

/// State for onboarding flow.
class OnboardingState {
  final int currentStep;
  final int totalSteps;
  final String studentName;
  final String? selectedProgram;
  final int? selectedSemester;
  final List<String> selectedSubjectIds;
  final bool isComplete;

  const OnboardingState({
    this.currentStep = 0,
    this.totalSteps = 4,
    this.studentName = '',
    this.selectedProgram,
    this.selectedSemester,
    this.selectedSubjectIds = const [],
    this.isComplete = false,
  });

  OnboardingState copyWith({
    int? currentStep,
    int? totalSteps,
    String? studentName,
    String? selectedProgram,
    int? selectedSemester,
    List<String>? selectedSubjectIds,
    bool? isComplete,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      studentName: studentName ?? this.studentName,
      selectedProgram: selectedProgram ?? this.selectedProgram,
      selectedSemester: selectedSemester ?? this.selectedSemester,
      selectedSubjectIds: selectedSubjectIds ?? this.selectedSubjectIds,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  double get progress => (currentStep + 1) / totalSteps;
}

class OnboardingViewModel extends BaseViewModel {
  // TODO: Inject AcademicRepository when implementing
  
  OnboardingState _state = const OnboardingState();
  OnboardingState get state => _state;

  void updateState(OnboardingState newState) {
    _state = newState;
    notifyListeners();
  }

  void setStudentName(String name) {
    _state = _state.copyWith(studentName: name);
    notifyListeners();
  }

  void setProgram(String program) {
    _state = _state.copyWith(selectedProgram: program);
    notifyListeners();
  }

  void setSemester(int semester) {
    _state = _state.copyWith(selectedSemester: semester);
    notifyListeners();
  }

  void toggleSubject(String subjectId) {
    final current = List<String>.from(_state.selectedSubjectIds);
    if (current.contains(subjectId)) {
      current.remove(subjectId);
    } else {
      current.add(subjectId);
    }
    _state = _state.copyWith(selectedSubjectIds: current);
    notifyListeners();
  }

  void nextStep() {
    if (_state.currentStep < _state.totalSteps - 1) {
      _state = _state.copyWith(currentStep: _state.currentStep + 1);
      notifyListeners();
    }
  }

  void previousStep() {
    if (_state.currentStep > 0) {
      _state = _state.copyWith(currentStep: _state.currentStep - 1);
      notifyListeners();
    }
  }

  bool canProceed() {
    switch (_state.currentStep) {
      case 0:
        return _state.studentName.trim().isNotEmpty;
      case 1:
        return _state.selectedProgram != null;
      case 2:
        return _state.selectedSemester != null;
      case 3:
        return _state.selectedSubjectIds.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> completeOnboarding() async {
    setLoading(true);
    try {
      // TODO: Save academic profile via repository
      _state = _state.copyWith(isComplete: true);
      notifyListeners();
    } catch (e) {
      setError('Failed to save profile: $e');
    } finally {
      setLoading(false);
    }
  }
}

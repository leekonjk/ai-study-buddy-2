/// Onboarding ViewModel.
/// Manages state for the onboarding flow.
///
/// Layer: Presentation
/// Responsibility: Handle onboarding steps, academic profile creation.
/// Inputs: User input (name, program, semester, subjects).
/// Outputs: Onboarding state, navigation triggers.
///
/// Dependencies: AcademicRepository (injected via constructor)
library;

import 'package:studnet_ai_buddy/domain/entities/academic_profile.dart';
import 'package:studnet_ai_buddy/domain/entities/subject.dart';
import 'package:studnet_ai_buddy/domain/repositories/academic_repository.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';

/// Immutable state for onboarding flow.
class OnboardingState {
  final ViewState viewState;
  final int currentStep;
  final int totalSteps;
  final String studentName;
  final String? selectedProgram;
  final int? selectedSemester;
  final List<String> selectedSubjectIds;
  final bool hasExistingProfile;
  final bool isComplete;
  final String? errorMessage;

  const OnboardingState({
    this.viewState = ViewState.initial,
    this.currentStep = 0,
    this.totalSteps = 4,
    this.studentName = '',
    this.selectedProgram,
    this.selectedSemester,
    this.selectedSubjectIds = const [],
    this.hasExistingProfile = false,
    this.isComplete = false,
    this.errorMessage,
  });

  OnboardingState copyWith({
    ViewState? viewState,
    int? currentStep,
    int? totalSteps,
    String? studentName,
    String? selectedProgram,
    int? selectedSemester,
    List<String>? selectedSubjectIds,
    bool? hasExistingProfile,
    bool? isComplete,
    String? errorMessage,
  }) {
    return OnboardingState(
      viewState: viewState ?? this.viewState,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      studentName: studentName ?? this.studentName,
      selectedProgram: selectedProgram ?? this.selectedProgram,
      selectedSemester: selectedSemester ?? this.selectedSemester,
      selectedSubjectIds: selectedSubjectIds ?? this.selectedSubjectIds,
      hasExistingProfile: hasExistingProfile ?? this.hasExistingProfile,
      isComplete: isComplete ?? this.isComplete,
      errorMessage: errorMessage,
    );
  }

  /// Progress as a value between 0.0 and 1.0.
  double get progress => (currentStep + 1) / totalSteps;

  /// Whether the ViewModel is currently loading.
  bool get isLoading => viewState == ViewState.loading;

  /// Whether there is an error.
  bool get hasError => errorMessage != null;

  /// Whether all required fields are filled for current step.
  bool get canProceedFromCurrentStep {
    switch (currentStep) {
      case 0:
        return studentName.trim().isNotEmpty;
      case 1:
        return selectedProgram != null;
      case 2:
        return selectedSemester != null;
      case 3:
        return selectedSubjectIds.isNotEmpty;
      default:
        return false;
    }
  }

  /// Whether this is the last step.
  bool get isLastStep => currentStep >= totalSteps - 1;

  /// Whether this is the first step.
  bool get isFirstStep => currentStep == 0;
}

/// ViewModel for onboarding flow.
/// Coordinates with AcademicRepository to load/save academic profile.
class OnboardingViewModel extends BaseViewModel {
  final AcademicRepository _academicRepository;

  OnboardingViewModel({required AcademicRepository academicRepository})
    : _academicRepository = academicRepository;

  OnboardingState _state = const OnboardingState();
  OnboardingState get state => _state;

  // ─────────────────────────────────────────────────────────────────────────
  // Initialization
  // ─────────────────────────────────────────────────────────────────────────

  /// Checks if user already has an academic profile.
  /// Call this when the onboarding screen loads.
  Future<void> checkExistingProfile() async {
    _state = _state.copyWith(viewState: ViewState.loading);
    notifyListeners();

    final result = await _academicRepository.isOnboardingComplete();

    result.fold(
      onSuccess: (isComplete) {
        _state = _state.copyWith(
          viewState: ViewState.loaded,
          hasExistingProfile: isComplete,
          isComplete: isComplete,
        );
        notifyListeners();
      },
      onFailure: (failure) {
        _state = _state.copyWith(
          viewState: ViewState.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
    );
  }

  /// Loads existing profile data if available.
  Future<void> loadExistingProfile() async {
    _state = _state.copyWith(viewState: ViewState.loading);
    notifyListeners();

    final result = await _academicRepository.getAcademicProfile();

    result.fold(
      onSuccess: (profile) {
        if (profile != null) {
          _state = _state.copyWith(
            viewState: ViewState.loaded,
            studentName: profile.studentName,
            selectedProgram: profile.programName,
            selectedSemester: profile.currentSemester,
            selectedSubjectIds: profile.enrolledSubjectIds,
            hasExistingProfile: true,
          );
        } else {
          _state = _state.copyWith(viewState: ViewState.loaded);
        }
        notifyListeners();
      },
      onFailure: (failure) {
        _state = _state.copyWith(
          viewState: ViewState.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step Navigation
  // ─────────────────────────────────────────────────────────────────────────

  /// Moves to the next step if possible.
  void nextStep() {
    if (_state.canProceedFromCurrentStep && !_state.isLastStep) {
      _state = _state.copyWith(
        currentStep: _state.currentStep + 1,
        errorMessage: null,
      );
      notifyListeners();
    }
  }

  /// Moves to the previous step if possible.
  void previousStep() {
    if (!_state.isFirstStep) {
      _state = _state.copyWith(
        currentStep: _state.currentStep - 1,
        errorMessage: null,
      );
      notifyListeners();
    }
  }

  /// Jumps to a specific step.
  void goToStep(int step) {
    if (step >= 0 && step < _state.totalSteps) {
      _state = _state.copyWith(currentStep: step, errorMessage: null);
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Data Input Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Sets the student name.
  void setStudentName(String name) {
    _state = _state.copyWith(studentName: name);
    notifyListeners();
  }

  /// Sets the selected program.
  void setProgram(String program) {
    _state = _state.copyWith(selectedProgram: program);
    notifyListeners();
  }

  /// Sets the selected semester.
  void setSemester(int semester) {
    _state = _state.copyWith(selectedSemester: semester);
    notifyListeners();
  }

  /// Toggles a subject in the selection list.
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

  /// Clears all selected subjects.
  void clearSubjects() {
    _state = _state.copyWith(selectedSubjectIds: []);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Profile Saving
  // ─────────────────────────────────────────────────────────────────────────

  /// Saves the academic profile and completes onboarding.
  Future<void> completeOnboarding() async {
    if (!_state.canProceedFromCurrentStep) {
      _state = _state.copyWith(
        errorMessage: 'Please complete all required fields',
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(viewState: ViewState.loading);
    notifyListeners();

    // Build the academic profile from state
    final profile = AcademicProfile(
      id: '', // Will be set by repository based on auth
      studentName: _state.studentName,
      universityName: '', // Not collected in this VM flow yet
      programName: _state.selectedProgram ?? '',
      currentSemester: _state.selectedSemester ?? 1,
      enrolledSubjectIds: _state.selectedSubjectIds,
      enrollmentDate: DateTime.now(),
      lastUpdated: DateTime.now(),
    );

    // Save profile
    final saveResult = await _academicRepository.saveAcademicProfile(profile);

    await saveResult.fold(
      onSuccess: (_) async {
        // Mark onboarding as complete
        final completeResult = await _academicRepository.completeOnboarding();

        completeResult.fold(
          onSuccess: (_) {
            _state = _state.copyWith(
              viewState: ViewState.loaded,
              isComplete: true,
              hasExistingProfile: true,
            );
            notifyListeners();
          },
          onFailure: (failure) {
            _state = _state.copyWith(
              viewState: ViewState.error,
              errorMessage: failure.message,
            );
            notifyListeners();
          },
        );
      },
      onFailure: (failure) {
        _state = _state.copyWith(
          viewState: ViewState.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Clears any error message.
  void dismissError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }

  /// Resets the entire onboarding state.
  void reset() {
    _state = const OnboardingState();
    notifyListeners();
  }

  /// Builds a list of Subject entities from selected IDs.
  /// Used when saving subjects to Firestore.
  List<Subject> buildSubjectList(Map<String, String> subjectNames) {
    return _state.selectedSubjectIds.map((id) {
      return Subject(
        id: id,
        name: subjectNames[id] ?? 'Unknown Subject',
        code: id,
        creditHours: 3, // Default
        difficulty: SubjectDifficulty.intermediate,
        topicIds: [],
      );
    }).toList();
  }
}

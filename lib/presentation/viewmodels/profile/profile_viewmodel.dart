/// Profile ViewModel.
/// Manages state for the user profile screen.
library;

import 'package:studnet_ai_buddy/core/utils/result.dart'; // Added

import 'package:firebase_auth/firebase_auth.dart';
import 'package:studnet_ai_buddy/domain/repositories/academic_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/focus_session_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/achievement_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/note_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/quiz_repository.dart';
import 'package:studnet_ai_buddy/domain/services/notification_service.dart'; // Added
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';

import 'package:studnet_ai_buddy/domain/entities/achievement.dart';

import 'package:studnet_ai_buddy/domain/entities/academic_profile.dart';

class ProfileState {
  final ViewState viewState;
  final String displayName;
  final String email;
  final String photoUrl;
  final int streakDays;
  final int quizzesCompleted;
  final int totalStudyHours;
  final List<Achievement> achievements;
  final AcademicProfile? academicProfile; // Added
  final String? errorMessage;

  const ProfileState({
    this.viewState = ViewState.initial,
    this.displayName = '',
    this.email = '',
    this.photoUrl = '',
    this.streakDays = 0,
    this.quizzesCompleted = 0,
    this.totalStudyHours = 0,
    this.achievements = const [],
    this.academicProfile, // Added
    this.errorMessage,
  });

  ProfileState copyWith({
    ViewState? viewState,
    String? displayName,
    String? email,
    String? photoUrl,
    int? streakDays,
    int? quizzesCompleted,
    int? totalStudyHours,
    List<Achievement>? achievements,
    AcademicProfile? academicProfile, // Added
    String? errorMessage,
  }) {
    return ProfileState(
      viewState: viewState ?? this.viewState,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      streakDays: streakDays ?? this.streakDays,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      totalStudyHours: totalStudyHours ?? this.totalStudyHours,
      achievements: achievements ?? this.achievements,
      academicProfile: academicProfile ?? this.academicProfile, // Added
      errorMessage: errorMessage,
    );
  }
}

class ProfileViewModel extends BaseViewModel {
  final AcademicRepository _academicRepository;
  final FocusSessionRepository _focusSessionRepository;
  final AchievementRepository _achievementRepository;
  final NoteRepository _noteRepository;
  final QuizRepository _quizRepository;
  final NotificationService _notificationService;
  final FirebaseAuth _auth;

  ProfileViewModel({
    required AcademicRepository academicRepository,
    required FocusSessionRepository focusSessionRepository,
    required AchievementRepository achievementRepository,
    required NoteRepository noteRepository,
    required QuizRepository quizRepository,
    required NotificationService notificationService,
    required FirebaseAuth auth,
  }) : _academicRepository = academicRepository,
       _focusSessionRepository = focusSessionRepository,
       _achievementRepository = achievementRepository,
       _noteRepository = noteRepository,
       _quizRepository = quizRepository,
       _notificationService = notificationService,
       _auth = auth;

  ProfileState _state = const ProfileState();
  ProfileState get state => _state;

  Future<void> loadProfile() async {
    _state = _state.copyWith(viewState: ViewState.loading);
    notifyListeners();

    final user = _auth.currentUser;
    if (user == null) {
      _state = _state.copyWith(
        viewState: ViewState.error,
        errorMessage: 'User not logged in',
      );
      notifyListeners();
      return;
    }

    // Basic Info
    String displayName = user.displayName ?? 'Student';
    final email = user.email ?? '';
    final photoUrl = user.photoURL ?? '';

    // Try to get name from Academic Profile if available
    final profileResult = await _academicRepository.getAcademicProfile();
    AcademicProfile? loadedProfile;
    profileResult.fold(
      onSuccess: (p) {
        if (p != null) {
          displayName = p.studentName;
          loadedProfile = p;
        }
      },
      onFailure: (_) {},
    );

    // Load Stats
    final sessionsResult = await _focusSessionRepository.getWeeklyFocusStats();

    int streak = 0;
    int totalMinutes = 0;

    sessionsResult.fold(
      onSuccess: (stats) {
        streak = _calculateStreak(stats);
        totalMinutes = stats.values.fold(0, (sum, val) => sum + val);
      },
      onFailure: (_) {},
    );

    // Load Note Count
    int totalNotes = 0;
    final notesResult = await _noteRepository.getNoteCount(user.uid);
    notesResult.fold(
      onSuccess: (count) => totalNotes = count,
      onFailure: (_) {},
    );

    // Load Quiz Count from all enrolled subjects
    int quizzesCompleted = 0;
    final subjectsResult = await _academicRepository.getEnrolledSubjects();
    subjectsResult.fold(
      onSuccess: (subjects) async {
        for (final subject in subjects) {
          final quizHistoryResult = await _quizRepository.getQuizHistory(
            subject.id,
          );
          quizHistoryResult.fold(
            onSuccess: (quizzes) => quizzesCompleted += quizzes.length,
            onFailure: (_) {},
          );
        }
      },
      onFailure: (_) {},
    );

    // Check & Unlock Achievements
    final unlockResult = await _achievementRepository
        .checkAndUnlockAchievements(
          totalStudyMinutes: totalMinutes,
          totalNotes: totalNotes,
          totalSessions: totalMinutes > 0 ? 1 : 0,
          studyStreak: streak,
        );

    // Notify about new unlocks
    if (unlockResult is Success) {
      final newUnlocks = (unlockResult as Success<List<Achievement>>).value;
      for (final achievement in newUnlocks) {
        // Show local notification
        await _notificationService.showNotification(
          title: 'Badge Unlocked: ${achievement.title}!',
          body: achievement.description,
        );
      }
    }

    // Load Achievements (now including newly unlocked ones)
    final achievementResult = await _achievementRepository.getAchievements();
    List<Achievement> achievements = [];
    achievementResult.fold(
      onSuccess: (list) => achievements = list,
      onFailure: (_) {},
    );

    _state = _state.copyWith(
      viewState: ViewState.loaded,
      displayName: displayName,
      email: email,
      photoUrl: photoUrl,
      streakDays: streak,
      totalStudyHours: totalMinutes ~/ 60,
      quizzesCompleted: quizzesCompleted,
      academicProfile: loadedProfile,
      achievements: achievements,
    );
    notifyListeners();
  }

  Future<void> updateProfile(AcademicProfile profile) async {
    _state = _state.copyWith(viewState: ViewState.loading);
    notifyListeners();

    final result = await _academicRepository.saveAcademicProfile(profile);

    result.fold(
      onSuccess: (_) {
        _state = _state.copyWith(
          viewState: ViewState.loaded,
          displayName: profile.studentName,
          academicProfile: profile,
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

  int _calculateStreak(Map<String, int> weeklyStats) {
    return weeklyStats.values.where((v) => v > 0).length;
  }
}

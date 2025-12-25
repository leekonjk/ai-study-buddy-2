/// App Router
/// Centralized navigation and route management.
library;

import 'package:flutter/material.dart';

// Screens
import 'package:studnet_ai_buddy/presentation/auth/auth_gate.dart';
import 'package:studnet_ai_buddy/presentation/auth/login_screen.dart';
import 'package:studnet_ai_buddy/presentation/navigation/app_transitions.dart';
import 'package:studnet_ai_buddy/presentation/navigation/main_shell.dart';
import 'package:studnet_ai_buddy/presentation/screens/calendar/calendar_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/explore/explore_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/focus/focus_session_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/intro/intro_onboarding_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/library/library_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/mentor/ai_chat_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/mentor/ai_mentor_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/onboarding/onboarding_flow.dart';
import 'package:studnet_ai_buddy/presentation/screens/planner/enhanced_ai_planner_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/profile/profile_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/profile_setup/profile_setup_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/quiz/quiz_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/quiz/quiz_setup_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/study_plan/study_plan_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/subjects/subject_detail_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/subjects/subjects_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/notes/notes_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/achievements/achievements_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/statistics/statistics_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/settings/settings_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/quiz/quiz_review_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/study/create_study_set_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/study/add_flashcards_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/study/study_set_detail_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/study/flashcard_screen.dart';

/// Route name constants.
class AppRoutes {
  AppRoutes._();

  static const String authGate = '/auth';
  static const String login = '/login';
  static const String introOnboarding = '/intro';
  static const String onboardingFlow = '/onboarding';
  static const String profileSetup = '/profile-setup';
  static const String dashboard = '/dashboard';
  static const String mainShell = '/main';
  static const String library = '/library';
  static const String explore = '/explore';
  static const String subjects = '/subjects';
  static const String subjectDetail = '/subject-detail';
  static const String quiz = '/quiz';
  static const String quizSetup = '/quiz-setup';
  static const String focusSession = '/focus-session';
  static const String studyPlan = '/study-plan';
  static const String aiMentor = '/ai-mentor';
  static const String aiChat = '/ai-chat';
  static const String aiPlanner = '/ai-planner';
  static const String profile = '/profile';
  static const String calendar = '/calendar';
  static const String notes = '/notes';
  static const String achievements = '/achievements';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
  static const String quizReview = '/quiz-review';
  static const String createStudySet = '/create-study-set';
  static const String addFlashcards = '/add-flashcards';
  static const String studySetDetail = '/study-set-detail';
  static const String flashcardStudy = '/flashcard-study';
}

/// App router for navigation.
class AppRouter {
  AppRouter._();

  /// Generate route based on settings.
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.authGate:
        return AppFadeRoute(page: const AuthGate());

      case AppRoutes.login:
        return AppFadeSlideRoute(page: const LoginScreen());

      case AppRoutes.introOnboarding:
        return AppFadeRoute(page: const IntroOnboardingScreen());

      case AppRoutes.onboardingFlow:
        return AppFadeRoute(page: const OnboardingFlow());

      case AppRoutes.mainShell:
        return AppFadeRoute(page: const MainShell());

      case AppRoutes.library:
        return AppSlideRightRoute(page: const LibraryScreen());

      case AppRoutes.explore:
        return AppSlideRightRoute(page: const ExploreScreen());

      case AppRoutes.profileSetup:
        return AppSlideRightRoute(page: const ProfileSetupScreen());

      case AppRoutes.dashboard:
        return AppFadeRoute(page: const DashboardScreen());

      case AppRoutes.subjects:
        return AppSlideRightRoute(page: const SubjectsScreen());

      case AppRoutes.subjectDetail:
        final subjectId = settings.arguments as String?;
        return AppSlideRightRoute(
          page: SubjectDetailScreen(subjectId: subjectId ?? ''),
        );

      case AppRoutes.quiz:
        final subjectId = settings.arguments as String?;
        return AppSlideRightRoute(page: QuizScreen(subjectId: subjectId ?? ''));

      case AppRoutes.quizSetup:
        final subjectId = settings.arguments as String?;
        return AppSlideRightRoute(page: QuizSetupScreen(subjectId: subjectId));

      case AppRoutes.focusSession:
        final args = settings.arguments as Map<String, dynamic>?;
        return AppSlideRightRoute(
          page: FocusSessionScreen(
            taskId: args?['taskId'],
            subjectId: args?['subjectId'],
          ),
        );

      case AppRoutes.studyPlan:
        return AppSlideRightRoute(page: const StudyPlanScreen());

      case AppRoutes.aiMentor:
        return AppSlideRightRoute(page: const AIMentorScreen());

      case AppRoutes.aiChat:
        final subjectTitle = settings.arguments as String?;
        return AppSlideRightRoute(
          page: AIChatScreen(subjectTitle: subjectTitle),
        );

      case AppRoutes.aiPlanner:
        return AppSlideRightRoute(page: const EnhancedAIPlannerScreen());

      case AppRoutes.profile:
        return AppSlideRightRoute(page: const ProfileScreen());

      case AppRoutes.calendar:
        return AppSlideRightRoute(page: const CalendarScreen());

      case AppRoutes.notes:
        return AppSlideRightRoute(page: const NotesScreen());

      case AppRoutes.achievements:
        return AppSlideRightRoute(page: const AchievementsScreen());

      case AppRoutes.statistics:
        return AppSlideRightRoute(page: const StatisticsScreen());

      case AppRoutes.settings:
        return AppSlideRightRoute(page: const SettingsScreen());

      case AppRoutes.quizReview:
        final args = settings.arguments as Map<String, dynamic>?;
        return AppSlideRightRoute(
          page: QuizReviewScreen(
            quizTitle: args?['quizTitle'] ?? 'Quiz',
            score: args?['score'] ?? 0,
            totalQuestions: args?['totalQuestions'] ?? 0,
          ),
        );

      case AppRoutes.createStudySet:
        return AppSlideRightRoute(page: const CreateStudySetScreen());

      case AppRoutes.addFlashcards:
        final args = settings.arguments as Map<String, dynamic>?;
        return AppSlideRightRoute(
          page: AddFlashcardsScreen(
            studySetTitle: args?['studySetTitle'] ?? '',
            studySetCategory: args?['studySetCategory'] ?? 'General',
            studySetDescription: args?['studySetDescription'] ?? '',
            isPrivate: args?['isPrivate'] ?? true,
          ),
        );

      case AppRoutes.studySetDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return AppSlideRightRoute(
          page: StudySetDetailScreen(
            studySetId: args?['studySetId'] ?? '',
            title: args?['title'],
            category: args?['category'],
          ),
        );

      case AppRoutes.flashcardStudy:
        final args = settings.arguments as Map<String, dynamic>?;
        return AppSlideRightRoute(
          page: FlashcardScreen(
            studySetId: args?['studySetId'] ?? '',
            studySetTitle: args?['title'] ?? 'Flashcards',
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

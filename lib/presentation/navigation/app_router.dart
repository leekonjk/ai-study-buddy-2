/// App Router.
/// Centralized navigation configuration.
/// 
/// Layer: Presentation
/// Responsibility: Define routes and navigation logic.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/focus/focus_session_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/mentor/ai_mentor_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/quiz/quiz_screen.dart';
import 'package:studnet_ai_buddy/presentation/screens/study_plan/study_plan_screen.dart';

/// Route names as constants.
class AppRoutes {
  AppRoutes._();

  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String studyPlan = '/study-plan';
  static const String quiz = '/quiz';
  static const String focusSession = '/focus-session';
  static const String aiMentor = '/ai-mentor';
}

/// Route generator for MaterialApp.
class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.onboarding:
        return _buildRoute(const OnboardingScreen(), settings);

      case AppRoutes.dashboard:
        return _buildRoute(const DashboardScreen(), settings);

      case AppRoutes.studyPlan:
        return _buildRoute(const StudyPlanScreen(), settings);

      case AppRoutes.quiz:
        // TODO: Extract subjectId from arguments
        return _buildRoute(const QuizScreen(), settings);

      case AppRoutes.focusSession:
        // TODO: Extract taskId from arguments
        return _buildRoute(const FocusSessionScreen(), settings);

      case AppRoutes.aiMentor:
        return _buildRoute(const AIMentorScreen(), settings);

      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}

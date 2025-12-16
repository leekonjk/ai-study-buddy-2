/// Service Locator.
/// Dependency injection setup using get_it.
/// 
/// Layer: Infrastructure
/// Responsibility: Register and provide dependencies across the app.
/// 
/// Registration Order:
/// 1. Firebase services (singletons)
/// 2. Repositories (lazy singletons)
/// 3. Domain services (lazy singletons)
/// 4. ViewModels (factories - new instance per screen)
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Domain Repositories
import 'package:studnet_ai_buddy/domain/repositories/academic_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/focus_session_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/quiz_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/study_plan_repository.dart';

// Repository Implementations
import 'package:studnet_ai_buddy/data/repositories/academic_repository_impl.dart';
import 'package:studnet_ai_buddy/data/repositories/focus_session_repository_impl.dart';
import 'package:studnet_ai_buddy/data/repositories/quiz_repository_impl.dart';
import 'package:studnet_ai_buddy/data/repositories/study_plan_repository_impl.dart';

// Domain Services
import 'package:studnet_ai_buddy/domain/services/ai_mentor_service.dart';
import 'package:studnet_ai_buddy/domain/services/knowledge_estimation_service.dart';
import 'package:studnet_ai_buddy/domain/services/risk_analysis_service.dart';
import 'package:studnet_ai_buddy/domain/services/study_planner_service.dart';

// Domain Service Implementations
import 'package:studnet_ai_buddy/domain/services/impl/ai_mentor_service_impl.dart';
import 'package:studnet_ai_buddy/domain/services/impl/knowledge_estimation_service_impl.dart';
import 'package:studnet_ai_buddy/domain/services/impl/risk_analysis_service_impl.dart';
import 'package:studnet_ai_buddy/domain/services/impl/study_planner_service_impl.dart';

// ViewModels
import 'package:studnet_ai_buddy/presentation/viewmodels/dashboard/dashboard_viewmodel.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/focus/focus_session_viewmodel.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/mentor/ai_mentor_viewmodel.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/onboarding/onboarding_viewmodel.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/quiz/quiz_viewmodel.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// Initializes all dependencies.
/// Call this in main() before runApp().
Future<void> initializeDependencies() async {
  // Register Firebase services
  _registerFirebaseServices();

  // Register repositories
  _registerRepositories();

  // Register domain services
  _registerDomainServices();

  // Register ViewModels
  _registerViewModels();
}

/// Registers Firebase services as singletons.
void _registerFirebaseServices() {
  // FirebaseFirestore singleton
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // FirebaseAuth singleton
  getIt.registerLazySingleton<FirebaseAuth>(
    () => FirebaseAuth.instance,
  );
}

/// Returns the current student ID from Firebase Auth.
/// Falls back to a default ID if not authenticated.
String _getCurrentStudentId() {
  final auth = getIt<FirebaseAuth>();
  return auth.currentUser?.uid ?? 'anonymous_user';
}

/// Registers repository implementations as lazy singletons.
void _registerRepositories() {
  // AcademicRepository
  getIt.registerLazySingleton<AcademicRepository>(
    () => AcademicRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      currentStudentId: _getCurrentStudentId(),
    ),
  );

  // QuizRepository
  getIt.registerLazySingleton<QuizRepository>(
    () => QuizRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      currentStudentId: _getCurrentStudentId(),
    ),
  );

  // StudyPlanRepository
  getIt.registerLazySingleton<StudyPlanRepository>(
    () => StudyPlanRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      currentStudentId: _getCurrentStudentId(),
    ),
  );

  // FocusSessionRepository
  getIt.registerLazySingleton<FocusSessionRepository>(
    () => FocusSessionRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      currentStudentId: _getCurrentStudentId(),
    ),
  );
}

/// Registers domain services as lazy singletons.
/// Domain services contain pure business logic, no dependencies on repositories.
void _registerDomainServices() {
  // KnowledgeEstimationService
  getIt.registerLazySingleton<KnowledgeEstimationService>(
    () => KnowledgeEstimationServiceImpl(),
  );

  // StudyPlannerService
  getIt.registerLazySingleton<StudyPlannerService>(
    () => StudyPlannerServiceImpl(),
  );

  // RiskAnalysisService
  getIt.registerLazySingleton<RiskAnalysisService>(
    () => RiskAnalysisServiceImpl(),
  );

  // AIMentorService
  getIt.registerLazySingleton<AIMentorService>(
    () => AIMentorServiceImpl(),
  );
}

/// Registers ViewModels as factories (new instance each time).
/// ViewModels are created fresh for each screen to avoid stale state.
void _registerViewModels() {
  // OnboardingViewModel
  getIt.registerFactory<OnboardingViewModel>(
    () => OnboardingViewModel(
      academicRepository: getIt<AcademicRepository>(),
    ),
  );

  // DashboardViewModel
  getIt.registerFactory<DashboardViewModel>(
    () => DashboardViewModel(
      studyPlanRepository: getIt<StudyPlanRepository>(),
      focusSessionRepository: getIt<FocusSessionRepository>(),
      academicRepository: getIt<AcademicRepository>(),
    ),
  );

  // QuizViewModel
  getIt.registerFactory<QuizViewModel>(
    () => QuizViewModel(
      quizRepository: getIt<QuizRepository>(),
      knowledgeEstimationService: getIt<KnowledgeEstimationService>(),
    ),
  );

  // FocusSessionViewModel
  getIt.registerFactory<FocusSessionViewModel>(
    () => FocusSessionViewModel(
      focusSessionRepository: getIt<FocusSessionRepository>(),
    ),
  );

  // AIMentorViewModel
  getIt.registerFactory<AIMentorViewModel>(
    () => AIMentorViewModel(
      aiMentorService: getIt<AIMentorService>(),
    ),
  );
}

/// Resets all registrations. Useful for testing.
Future<void> resetDependencies() async {
  await getIt.reset();
}

/// Convenience accessor for repositories.
AcademicRepository get academicRepository => getIt<AcademicRepository>();
QuizRepository get quizRepository => getIt<QuizRepository>();
StudyPlanRepository get studyPlanRepository => getIt<StudyPlanRepository>();
FocusSessionRepository get focusSessionRepository => getIt<FocusSessionRepository>();

/// Convenience accessor for domain services.
KnowledgeEstimationService get knowledgeEstimationService => getIt<KnowledgeEstimationService>();
StudyPlannerService get studyPlannerService => getIt<StudyPlannerService>();
RiskAnalysisService get riskAnalysisService => getIt<RiskAnalysisService>();

/// Convenience accessor for ViewModels.
OnboardingViewModel get onboardingViewModel => getIt<OnboardingViewModel>();
DashboardViewModel get dashboardViewModel => getIt<DashboardViewModel>();
QuizViewModel get quizViewModel => getIt<QuizViewModel>();
FocusSessionViewModel get focusSessionViewModel => getIt<FocusSessionViewModel>();
AIMentorViewModel get aiMentorViewModel => getIt<AIMentorViewModel>();

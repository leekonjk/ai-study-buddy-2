/// Service Locator.
/// Dependency injection setup using get_it.
///
/// Layer: Infrastructure
/// Responsibility: Register and provide dependencies across the app.
///
/// Registration Order:
/// 1. Firebase services (singletons)
/// 2. Local services (lazy singletons)
/// 3. Repositories (lazy singletons)
/// 4. Domain services (lazy singletons)
/// 5. ViewModels (factories - new instance per screen)
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

// Domain Repositories
import 'package:studnet_ai_buddy/domain/repositories/academic_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/focus_session_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/quiz_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/study_plan_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/study_set_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/note_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/flashcard_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/achievement_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/file_repository.dart'; // Added

import 'package:studnet_ai_buddy/domain/repositories/resource_repository.dart';

// Repository Implementations
import 'package:studnet_ai_buddy/data/repositories/academic_repository_impl.dart';
import 'package:studnet_ai_buddy/data/repositories/focus_session_repository_impl.dart';
import 'package:studnet_ai_buddy/data/repositories/quiz_repository_impl.dart';
import 'package:studnet_ai_buddy/data/repositories/study_plan_repository_impl.dart';
import 'package:studnet_ai_buddy/data/repositories/study_set_repository_impl.dart';
import 'package:studnet_ai_buddy/data/repositories/note_repository_impl.dart';
import 'package:studnet_ai_buddy/data/repositories/flashcard_repository_impl.dart';
import 'package:studnet_ai_buddy/data/repositories/resource_repository_impl.dart';
import 'package:studnet_ai_buddy/data/repositories/achievement_repository_impl.dart';
import 'package:studnet_ai_buddy/data/repositories/file_repository_impl.dart'; // Added

// Domain Services
import 'package:studnet_ai_buddy/domain/services/ai_mentor_service.dart';
import 'package:studnet_ai_buddy/domain/services/file_upload_service.dart';
import 'package:studnet_ai_buddy/domain/services/knowledge_estimation_service.dart';
import 'package:studnet_ai_buddy/domain/services/local_storage_service.dart';
import 'package:studnet_ai_buddy/domain/services/notification_service.dart';
import 'package:studnet_ai_buddy/domain/services/risk_analysis_service.dart';
import 'package:studnet_ai_buddy/domain/services/study_planner_service.dart';

// Domain Service Implementations
import 'package:studnet_ai_buddy/domain/services/impl/ai_mentor_service_impl.dart';
import 'package:studnet_ai_buddy/domain/services/impl/achievement_service_impl.dart';
import 'package:studnet_ai_buddy/domain/services/impl/knowledge_estimation_service_impl.dart';
import 'package:studnet_ai_buddy/domain/services/impl/risk_analysis_service_impl.dart';
import 'package:studnet_ai_buddy/domain/services/impl/study_planner_service_impl.dart';
import 'package:studnet_ai_buddy/data/services/file_upload_service_impl.dart';
import 'package:studnet_ai_buddy/data/services/local_storage_service_impl.dart';
import 'package:studnet_ai_buddy/data/services/notification_service_impl.dart';

// ViewModels
import 'package:studnet_ai_buddy/presentation/viewmodels/dashboard/dashboard_viewmodel.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/focus/focus_session_viewmodel.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/mentor/ai_mentor_viewmodel.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/onboarding/onboarding_viewmodel.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/profile/profile_viewmodel.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/quiz/quiz_viewmodel.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/planner/ai_planner_viewmodel.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/notes/notes_viewmodel.dart';

import 'package:studnet_ai_buddy/presentation/viewmodels/library/library_viewmodel.dart'; // Added
import 'package:studnet_ai_buddy/presentation/viewmodels/statistics/statistics_viewmodel.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// Initializes all dependencies.
/// Call this in main() before runApp().
Future<void> initializeDependencies() async {
  // Register Firebase services
  _registerFirebaseServices();

  // Register local services
  _registerLocalServices();

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
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
}

/// Registers local services as lazy singletons.
void _registerLocalServices() {
  // LocalStorageService
  getIt.registerLazySingleton<LocalStorageService>(
    () => LocalStorageServiceImpl(),
  );

  // NotificationService
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationServiceImpl(),
  );

  // FileUploadService
  getIt.registerLazySingleton<FileUploadService>(() => FileUploadServiceImpl());
}

/// Registers repository implementations as lazy singletons.
void _registerRepositories() {
  // AcademicRepository
  getIt.registerLazySingleton<AcademicRepository>(
    () => AcademicRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  // QuizRepository
  getIt.registerLazySingleton<QuizRepository>(
    () => QuizRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
      aiService: getIt<AIMentorService>(),
    ),
  );

  // StudyPlanRepository
  getIt.registerLazySingleton<StudyPlanRepository>(
    () => StudyPlanRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  // FocusSessionRepository
  getIt.registerLazySingleton<FocusSessionRepository>(
    () => FocusSessionRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  // StudySetRepository
  getIt.registerLazySingleton<StudySetRepository>(
    () => StudySetRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  // NoteRepository
  getIt.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  // FlashcardRepository
  getIt.registerLazySingleton<FlashcardRepository>(
    () => FlashcardRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  // ResourceRepository
  getIt.registerLazySingleton<ResourceRepository>(
    () => ResourceRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  // AchievementRepository
  getIt.registerLazySingleton<AchievementRepository>(
    () => AchievementRepositoryImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  // FileRepository
  getIt.registerLazySingleton<FileRepository>(
    () => FileRepositoryImpl(
      storage: null, // Default
      firestore: getIt<FirebaseFirestore>(),
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
  getIt.registerLazySingleton<AIMentorService>(() => AIMentorServiceImpl());

  // AchievementService
  getIt.registerLazySingleton<AchievementService>(
    () => AchievementService(
      achievementRepository: getIt<AchievementRepository>(),
    ),
  );
}

/// Registers ViewModels as factories (new instance each time).
/// ViewModels are created fresh for each screen to avoid stale state.
void _registerViewModels() {
  // OnboardingViewModel
  getIt.registerFactory<OnboardingViewModel>(
    () => OnboardingViewModel(academicRepository: getIt<AcademicRepository>()),
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
      flashcardRepository: getIt<FlashcardRepository>(),
      knowledgeEstimationService: getIt<KnowledgeEstimationService>(),
    ),
  );

  // FocusSessionViewModel
  getIt.registerFactory<FocusSessionViewModel>(
    () => FocusSessionViewModel(
      focusSessionRepository: getIt<FocusSessionRepository>(),
      achievementRepository: getIt<AchievementRepository>(),
    ),
  );

  // AIMentorViewModel
  getIt.registerFactory<AIMentorViewModel>(
    () => AIMentorViewModel(
      aiMentorService: getIt<AIMentorService>(),
      academicRepository: getIt<AcademicRepository>(),
    ),
  );

  // AIPlannerViewModel
  getIt.registerFactory<AIPlannerViewModel>(
    () => AIPlannerViewModel(
      studyPlanRepository: getIt<StudyPlanRepository>(),
      academicRepository: getIt<AcademicRepository>(),
      aiMentorService: getIt<AIMentorService>(),
    ),
  );

  // ProfileViewModel
  getIt.registerFactory<ProfileViewModel>(
    () => ProfileViewModel(
      academicRepository: getIt<AcademicRepository>(),
      focusSessionRepository: getIt<FocusSessionRepository>(),
      achievementRepository: getIt<AchievementRepository>(),
      noteRepository: getIt<NoteRepository>(),
      notificationService: getIt<NotificationService>(), // Added
      auth: getIt<FirebaseAuth>(),
    ),
  );

  // NotesViewModel
  getIt.registerFactory<NotesViewModel>(
    () => NotesViewModel(
      noteRepository: getIt<NoteRepository>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  // StatisticsViewModel
  getIt.registerFactory<StatisticsViewModel>(
    () => StatisticsViewModel(
      focusSessionRepository: getIt<FocusSessionRepository>(),
    ),
  );

  // LibraryViewModel
  getIt.registerFactory<LibraryViewModel>(
    () => LibraryViewModel(
      fileRepository: getIt<FileRepository>(),
      auth: getIt<FirebaseAuth>(),
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
FocusSessionRepository get focusSessionRepository =>
    getIt<FocusSessionRepository>();
FlashcardRepository get flashcardRepository => getIt<FlashcardRepository>();
StudySetRepository get studySetRepository => getIt<StudySetRepository>();
NoteRepository get noteRepository => getIt<NoteRepository>();
ResourceRepository get resourceRepository => getIt<ResourceRepository>();

/// Convenience accessor for domain services.
KnowledgeEstimationService get knowledgeEstimationService =>
    getIt<KnowledgeEstimationService>();
StudyPlannerService get studyPlannerService => getIt<StudyPlannerService>();
RiskAnalysisService get riskAnalysisService => getIt<RiskAnalysisService>();

/// Convenience accessor for ViewModels.
OnboardingViewModel get onboardingViewModel => getIt<OnboardingViewModel>();
DashboardViewModel get dashboardViewModel => getIt<DashboardViewModel>();
QuizViewModel get quizViewModel => getIt<QuizViewModel>();
FocusSessionViewModel get focusSessionViewModel =>
    getIt<FocusSessionViewModel>();
AIMentorViewModel get aiMentorViewModel => getIt<AIMentorViewModel>();
LibraryViewModel get libraryViewModel => getIt<LibraryViewModel>();

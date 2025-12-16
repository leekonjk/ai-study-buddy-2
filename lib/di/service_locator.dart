/// Service Locator.
/// Dependency injection setup using get_it or manual registration.
/// 
/// Layer: Infrastructure
/// Responsibility: Register and provide dependencies across the app.
library;

// TODO: Add get_it package to pubspec.yaml when implementing

/// Initializes all dependencies.
/// Call this in main() before runApp().
Future<void> initializeDependencies() async {
  // Register data sources
  _registerDataSources();

  // Register repositories
  _registerRepositories();

  // Register domain services
  _registerServices();

  // Register ViewModels
  _registerViewModels();
}

void _registerDataSources() {
  // TODO: Register LocalStorageService implementation
  // Example with get_it:
  // getIt.registerLazySingleton<LocalStorageService>(
  //   () => SharedPreferencesStorage(prefs),
  // );
}

void _registerRepositories() {
  // TODO: Register repository implementations
  // Example:
  // getIt.registerLazySingleton<AcademicRepository>(
  //   () => AcademicRepositoryImpl(getIt()),
  // );
}

void _registerServices() {
  // TODO: Register domain services
  // Example:
  // getIt.registerLazySingleton<KnowledgeEstimationService>(
  //   () => KnowledgeEstimationServiceImpl(),
  // );
}

void _registerViewModels() {
  // TODO: Register ViewModels as factories (new instance each time)
  // Example:
  // getIt.registerFactory<OnboardingViewModel>(
  //   () => OnboardingViewModel(getIt()),
  // );
}

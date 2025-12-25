import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/services/notification_service.dart';
import 'package:studnet_ai_buddy/domain/services/local_storage_service.dart';
import 'package:studnet_ai_buddy/presentation/auth/auth_gate.dart';
import 'package:flutter/services.dart';
import 'package:studnet_ai_buddy/presentation/navigation/app_router.dart';
import 'package:studnet_ai_buddy/presentation/screens/onboarding/onboarding_flow.dart';
import 'package:studnet_ai_buddy/presentation/screens/splash/splash_screen.dart';
import 'package:studnet_ai_buddy/presentation/design/design_system.dart';
import 'package:provider/provider.dart';
import 'package:studnet_ai_buddy/presentation/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize dependency injection
  await initializeDependencies();

  // Initialize Notification Service
  await getIt<NotificationService>().initialize();
  
  // Check if user has seen intro using LocalStorageService
  final localStorageService = getIt<LocalStorageService>();
  final hasSeenIntro = await localStorageService.hasSeenIntro();
  
  // Force edge-to-edge to ensure navbar is visible
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  // Debug logging for navigation decision
  debugPrint('═══════════════════════════════════════════════════');
  debugPrint('APP LAUNCH - Navigation Decision');
  debugPrint('hasSeenIntro: $hasSeenIntro');
  debugPrint('Initial Route: ${hasSeenIntro ? "AuthGate" : "OnboardingFlow"}');
  debugPrint('═══════════════════════════════════════════════════');

  runApp(AIStudyBuddyApp(hasSeenIntro: hasSeenIntro));
}

class AIStudyBuddyApp extends StatelessWidget {
  final bool hasSeenIntro;

  const AIStudyBuddyApp({
    super.key,
    required this.hasSeenIntro,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'AI Study Buddy',
            debugShowCheckedModeBanner: false,
            theme: AppDesignSystem.lightTheme,
            darkTheme: AppDesignSystem.darkTheme,
            themeMode: themeProvider.themeMode,
            home: SplashScreen(
              nextScreen: hasSeenIntro ? const AuthGate() : const OnboardingFlow(),
            ),
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}

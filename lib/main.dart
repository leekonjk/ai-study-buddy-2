import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/services/notification_service.dart';
import 'package:studnet_ai_buddy/domain/services/local_storage_service.dart';
import 'package:studnet_ai_buddy/presentation/auth/auth_gate.dart';
import 'package:flutter/services.dart';
import 'package:studnet_ai_buddy/presentation/navigation/app_router.dart';
import 'package:studnet_ai_buddy/presentation/screens/intro/intro_onboarding_screen.dart';
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

  // Initialize LocalStorageService
  final localStorageService = getIt<LocalStorageService>();
  await localStorageService.initialize();

  // Check if user has seen intro
  final hasSeenIntro = await localStorageService.hasSeenIntro();

  // Force edge-to-edge to ensure navbar is visible
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Lock orientation to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Debug logging for navigation decision
  debugPrint('═══════════════════════════════════════════════════');
  debugPrint('APP LAUNCH - Navigation Decision');
  debugPrint('hasSeenIntro: $hasSeenIntro');
  debugPrint('Initial Route: ${hasSeenIntro ? "AuthGate" : "IntroOnboarding"}');
  debugPrint('═══════════════════════════════════════════════════');

  runApp(AIStudyBuddyApp(hasSeenIntro: hasSeenIntro));
}

class AIStudyBuddyApp extends StatelessWidget {
  final bool hasSeenIntro;

  const AIStudyBuddyApp({super.key, required this.hasSeenIntro});

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
              // New users: Intro Onboarding → SignUp → Profile Setup → Main
              // Existing users: Auth Gate (Main)
              // If user is logged in, skip intro regardless of local flag
              nextScreen:
                  (hasSeenIntro || FirebaseAuth.instance.currentUser != null)
                  ? const AuthGate()
                  : const IntroOnboardingScreen(),
            ),
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}

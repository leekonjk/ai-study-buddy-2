/// Auth Gate
/// Handles authentication state and routes to appropriate screen.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/repositories/academic_repository.dart';
import 'package:studnet_ai_buddy/presentation/auth/login_screen.dart';
import 'package:studnet_ai_buddy/presentation/navigation/main_shell.dart';
import 'package:studnet_ai_buddy/presentation/screens/onboarding/onboarding_flow.dart';

/// Widget that listens to auth state and shows appropriate screen.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<bool>? _onboardingFuture;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    // Pre-fetch ONLY if user is already logged in?
    // Actually, we can't pre-fetch easily here because we depend on the stream.
    // But we can memoize the future based on User?
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // User is signed in - check onboarding status
        if (snapshot.hasData && user != null) {
          // Initialize or reset future if user changed
          if (_onboardingFuture == null || _currentUserId != user.uid) {
            _currentUserId = user.uid;
            _onboardingFuture = _checkOnboardingComplete(user.uid);
          }

          return FutureBuilder<bool>(
            future: _onboardingFuture,
            builder: (context, onboardingSnapshot) {
              // Show loading while checking onboarding status
              if (onboardingSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Handle errors gracefully
              if (onboardingSnapshot.hasError) {
                debugPrint("AuthGate Error: ${onboardingSnapshot.error}");
                // On error, default to safety (maybe user needs to retry or go to profile setup?)
                // Let's assume ProfileSetup is safer than crashing.
                return const OnboardingFlow();
              }

              // User hasn't completed onboarding - show profile setup
              if (onboardingSnapshot.data == false) {
                return const OnboardingFlow();
              }

              // User completed onboarding - show main app
              return const MainShell();
            },
          );
        }

        // User is not signed in - clear cache
        _onboardingFuture = null;
        _currentUserId = null;
        return const LoginScreen();
      },
    );
  }

  /// Check if user has completed onboarding
  Future<bool> _checkOnboardingComplete(String userId) async {
    try {
      final result = await getIt<AcademicRepository>().isOnboardingComplete();
      return result.fold(
        onSuccess: (hasCompleted) => hasCompleted,
        onFailure: (_) {
          return false;
        },
      );
    } catch (e) {
      debugPrint("AuthGate Exception: $e");
      return false;
    }
  }
}

/// Intro Onboarding Screen
/// Initial app introduction with Mascot.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/services/local_storage_service.dart';
import 'package:studnet_ai_buddy/presentation/navigation/app_router.dart';
import 'package:studnet_ai_buddy/presentation/theme/app_theme.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/gradient_scaffold.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/mascot_widget.dart';

/// Intro screen with Mascot.
class IntroOnboardingScreen extends StatefulWidget {
  const IntroOnboardingScreen({super.key});

  @override
  State<IntroOnboardingScreen> createState() => _IntroOnboardingScreenState();
}

class _IntroOnboardingScreenState extends State<IntroOnboardingScreen> {
  Future<void> _onContinue() async {
    // Mark intro as seen
    final localStorageService = getIt<LocalStorageService>();
    await localStorageService.setIntroSeen(true);

    if (mounted) {
      // Navigate to Login/Auth
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(),

              // Mascot
              const SizedBox(
                height: 200,
                width: 200,
                child: MascotWidget(expression: MascotExpression.happy),
              ).animate().fadeIn(duration: 600.ms).scale(),

              const SizedBox(height: 48),

              // Title
              Text(
                "Let's get started!",
                style: AppTypography.headline1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                "I'll help you set up your study profile and get you ready to learn smarter.",
                style: AppTypography.body1.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

              const Spacer(flex: 2),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 16),

              // Skip
              TextButton(
                onPressed: _onContinue,
                child: Text(
                  'Skip',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/repositories/achievement_repository.dart';

import 'package:studnet_ai_buddy/presentation/screens/achievements/achievements_screen.dart';
import 'package:studnet_ai_buddy/presentation/widgets/common/lottie_loading.dart';

/// Wrapper screen that loads achievements from Firebase and displays them
class AchievementsLoadingScreen extends StatefulWidget {
  const AchievementsLoadingScreen({super.key});

  @override
  State<AchievementsLoadingScreen> createState() =>
      _AchievementsLoadingScreenState();
}

class _AchievementsLoadingScreenState extends State<AchievementsLoadingScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Please log in to view achievements'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return FutureBuilder(
      future: getIt<AchievementRepository>().getAchievements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: LottieLoading(
                size: 120,
                message: 'Loading achievements...',
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Handle Result type from repository
        final result = snapshot.data;
        if (result == null) {
          return const Scaffold(body: Center(child: Text('No data available')));
        }

        return result.fold(
          onSuccess: (achievements) =>
              AchievementsScreen(achievements: achievements),
          onFailure: (failure) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${failure.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Auth Gate
/// Handles authentication state and routes to appropriate screen.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/auth/login_screen.dart';
import 'package:studnet_ai_buddy/presentation/navigation/main_shell.dart';

/// Widget that listens to auth state and shows appropriate screen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is signed in
        if (snapshot.hasData && snapshot.data != null) {
          return const MainShell();
        }

        // User is not signed in
        return const LoginScreen();
      },
    );
  }
}


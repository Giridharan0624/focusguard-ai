import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../home_screen.dart';
import 'login_screen.dart';
import 'profile_setup_screen.dart';

/// Listens to Firebase Auth state and routes to the correct screen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return StreamBuilder<User?>(
      stream: authVM.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        // User is logged in — check if profile exists
        return FutureBuilder<bool>(
          future: authVM.hasProfile(),
          builder: (context, profileSnap) {
            if (profileSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (profileSnap.data == true) {
              return const HomeScreen();
            }

            return const ProfileSetupScreen();
          },
        );
      },
    );
  }
}

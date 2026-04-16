import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../home_screen.dart';
import 'login_screen.dart';
import 'profile_setup_screen.dart';

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

        // If profile is loaded, go to home
        if (authVM.userProfile != null) {
          return const HomeScreen();
        }

        // Otherwise check Firestore
        return _ProfileCheck(authVM: authVM);
      },
    );
  }
}

class _ProfileCheck extends StatefulWidget {
  final AuthViewModel authVM;
  const _ProfileCheck({required this.authVM});

  @override
  State<_ProfileCheck> createState() => _ProfileCheckState();
}

class _ProfileCheckState extends State<_ProfileCheck> {
  late Future<bool> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _checkAndLoad();
  }

  Future<bool> _checkAndLoad() async {
    final exists = await widget.authVM.hasProfile();
    if (exists) {
      await widget.authVM.loadProfile();
    }
    return exists;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const HomeScreen();
        }

        return const ProfileSetupScreen();
      },
    );
  }
}

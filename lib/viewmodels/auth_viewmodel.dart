import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../data/user_repository.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final UserRepository _userRepository;

  bool isLoading = false;
  String? errorMessage;
  UserProfile? userProfile;

  AuthViewModel({
    required AuthService authService,
    required UserRepository userRepository,
  })  : _authService = authService,
        _userRepository = userRepository;

  Stream<User?> get authStateChanges => _authService.authStateChanges;
  User? get currentUser => _authService.currentUser;
  String? get uid => _authService.currentUser?.uid;

  /// Load user profile from Firestore after login.
  Future<void> loadProfile() async {
    final user = _authService.currentUser;
    if (user == null) return;

    userProfile = await _userRepository.getProfile(user.uid);
    notifyListeners();
  }

  /// Check if user has completed profile setup.
  Future<bool> hasProfile() async {
    final user = _authService.currentUser;
    if (user == null) return false;
    return _userRepository.profileExists(user.uid);
  }

  /// Save user profile (first-time setup or update).
  Future<void> saveProfile({
    required String name,
    int? age,
    String? occupation,
  }) async {
    final user = _authService.currentUser;
    if (user == null) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final profile = UserProfile(
        uid: user.uid,
        email: user.email ?? '',
        name: name,
        age: age,
        occupation: occupation,
      );
      await _userRepository.saveProfile(profile);
      userProfile = profile;
    } catch (e) {
      errorMessage = 'Failed to save profile.';
    }

    isLoading = false;
    notifyListeners();
  }

  /// Register with email and password.
  Future<bool> register(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.registerWithEmail(email, password);
      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _mapAuthError(e.code);
    } catch (e) {
      errorMessage = 'Registration failed. Please try again.';
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  /// Sign in with email and password.
  Future<bool> signIn(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithEmail(email, password);
      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _mapAuthError(e.code);
    } catch (e) {
      errorMessage = 'Sign in failed. Please try again.';
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  /// Sign in with Google.
  Future<bool> signInWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithGoogle();
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Google sign-in failed. Please try again.';
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  /// Sign out.
  Future<void> signOut() async {
    await _authService.signOut();
    userProfile = null;
    notifyListeners();
  }

  /// Delete account and all data.
  Future<void> deleteAccount() async {
    final user = _authService.currentUser;
    if (user == null) return;

    isLoading = true;
    notifyListeners();

    try {
      await _userRepository.deleteAccount(user.uid);
      await _authService.deleteAccount();
      userProfile = null;
    } catch (e) {
      errorMessage = 'Failed to delete account.';
    }

    isLoading = false;
    notifyListeners();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

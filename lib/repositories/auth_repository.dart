import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Repository handling all authentication operations with data layer abstraction.
class AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  /// Current authenticated user.
  User? get currentUser => _authService.currentUser;

  /// Auth state stream.
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  /// Register a new user.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final credential = await _authService.signUp(
      email: email,
      password: password,
    );

    if (credential?.user == null) {
      throw Exception('Registration failed. Please try again.');
    }

    final user = UserModel(
      uid: credential!.user!.uid,
      name: name,
      email: email,
      phone: phone,
      createdAt: DateTime.now(),
    );

    await _firestoreService.createUser(user);

    // Save login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.isLoggedInKey, true);
    await prefs.setString(AppConstants.userIdKey, user.uid);
    await prefs.setString(AppConstants.userEmailKey, email);
    await prefs.setString(AppConstants.userNameKey, name);

    return user;
  }

  /// Login existing user.
  Future<UserModel> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final credential = await _authService.signIn(
      email: email,
      password: password,
    );

    if (credential?.user == null) {
      throw Exception('Login failed. Please try again.');
    }

    final user = await _firestoreService.getUser(credential!.user!.uid);
    if (user == null) {
      throw Exception('User profile not found. Please contact support.');
    }

    // Update last login
    await _firestoreService.updateUser(user.uid, {
      'lastLogin': DateTime.now(),
    });

    // Save login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.isLoggedInKey, true);
    await prefs.setString(AppConstants.userIdKey, user.uid);
    await prefs.setString(AppConstants.userEmailKey, email);
    await prefs.setString(AppConstants.userNameKey, user.name);
    if (rememberMe) {
      await prefs.setBool(AppConstants.rememberMeKey, true);
      await prefs.setString('savedEmail', email);
      await prefs.setString('savedPassword', password);
    }

    return user;
  }

  /// Send password reset email.
  Future<void> resetPassword(String email) async {
    await _authService.sendPasswordReset(email);
  }

  /// Logout current user.
  Future<void> logout() async {
    await _authService.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.isLoggedInKey, false);
    await prefs.remove(AppConstants.userIdKey);
  }

  /// Get saved credentials if remember me was enabled.
  Future<Map<String, String>?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(AppConstants.rememberMeKey) ?? false;
    if (rememberMe) {
      return {
        'email': prefs.getString('savedEmail') ?? '',
        'password': prefs.getString('savedPassword') ?? '',
      };
    }
    return null;
  }

  /// Check if user is logged in.
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(AppConstants.isLoggedInKey) ?? false;
    if (loggedIn && _authService.useMock) {
      final uid = prefs.getString(AppConstants.userIdKey) ?? 'mock_uid_123';
      final email = prefs.getString(AppConstants.userEmailKey) ?? 'eco@champion.com';
      _authService.setMockUser(MockUser(uid: uid, email: email));
    }
    return loggedIn;
  }

  /// Check if onboarding was completed.
  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.onboardingCompleteKey) ?? false;
  }

  /// Mark onboarding as complete.
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingCompleteKey, true);
  }

  /// Update user profile.
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _firestoreService.updateUser(uid, data);
  }

  /// Get user profile.
  Future<UserModel?> getUserProfile(String uid) async {
    return await _firestoreService.getUser(uid);
  }

  /// Check if current user is admin.
  Future<bool> isAdmin() async {
    final user = _authService.currentUser;
    if (user == null) return false;
    final userModel = await _firestoreService.getUser(user.uid);
    return userModel?.isAdmin ?? false;
  }

  /// Delete user account.
  Future<void> deleteAccount(String uid) async {
    await _firestoreService.deleteUser(uid);
    await _authService.deleteAccount();
  }
}

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// Mock User implementation using noSuchMethod to satisfy the compiler interface.
class MockUser implements User {
  @override
  final String uid;
  
  @override
  final String? email;
  
  @override
  final bool emailVerified;

  MockUser({
    required this.uid,
    this.email = 'eco@champion.com',
    this.emailVerified = true,
  });

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #uid) return uid;
    if (invocation.memberName == #email) return email;
    if (invocation.memberName == #emailVerified) return emailVerified;
    return null;
  }
}

/// Mock UserCredential implementation.
class MockUserCredential implements UserCredential {
  @override
  final User? user;

  MockUserCredential(this.user);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #user) return user;
    return null;
  }
}

/// Firebase Authentication service handling all auth operations with Mock Mode support.
class AuthService {
  final FirebaseAuth? _auth;
  final bool useMock;

  User? _mockUser;
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();

  AuthService({this.useMock = false})
      : _auth = useMock ? null : FirebaseAuth.instance;

  /// Set the mock user manually (e.g. when restoring session from SharedPreferences).
  void setMockUser(User? user) {
    if (useMock) {
      _mockUser = user;
      _authStateController.add(user);
    }
  }

  /// Get current authenticated user.
  User? get currentUser => useMock ? _mockUser : _auth?.currentUser;

  /// Auth state change stream.
  Stream<User?> get authStateChanges =>
      useMock ? _authStateController.stream : _auth!.authStateChanges();

  /// Sign up with email and password.
  Future<UserCredential?> signUp({
    required String email,
    required String password,
  }) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      _mockUser = MockUser(uid: 'mock_uid_123', email: email);
      _authStateController.add(_mockUser);
      return MockUserCredential(_mockUser);
    }

    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Send email verification
      await credential.user?.sendEmailVerification();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign in with email and password.
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      _mockUser = MockUser(uid: 'mock_uid_123', email: email);
      _authStateController.add(_mockUser);
      return MockUserCredential(_mockUser);
    }

    try {
      return await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Send password reset email.
  Future<void> sendPasswordReset(String email) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    try {
      await _auth!.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Update user password.
  Future<void> updatePassword(String newPassword) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    try {
      await _auth!.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      _mockUser = null;
      _authStateController.add(null);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.isLoggedInKey, false);
      return;
    }

    await _auth!.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.isLoggedInKey, false);
  }

  /// Delete current user account.
  Future<void> deleteAccount() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      _mockUser = null;
      _authStateController.add(null);
      return;
    }

    try {
      await _auth!.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Check if email is verified.
  bool get isEmailVerified => useMock ? true : (_auth?.currentUser?.emailVerified ?? false);

  /// Reload user to check verification status.
  Future<void> reloadUser() async {
    if (useMock) return;
    await _auth!.currentUser?.reload();
  }

  /// Handle Firebase auth errors with user-friendly messages.
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Contact support.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}

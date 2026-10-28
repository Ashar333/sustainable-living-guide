import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

/// Authentication state provider managing user session.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider({required AuthRepository repository}) : _repository = repository;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  bool _onboardingComplete = false;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  bool get onboardingComplete => _onboardingComplete;
  bool get isAdmin => _user?.isAdmin ?? false;

  /// Initialize auth state on app start.
  Future<void> initialize() async {
    _isLoggedIn = await _repository.isLoggedIn();
    _onboardingComplete = await _repository.isOnboardingComplete();

    if (_isLoggedIn && _repository.currentUser != null) {
      _user = await _repository.getUserProfile(_repository.currentUser!.uid);
    }
    notifyListeners();
  }

  /// Register new user.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading(true);
    try {
      _user = await _repository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      _isLoggedIn = true;
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Login user.
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    try {
      _user = await _repository.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      _isLoggedIn = true;
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load saved credentials for remember me.
  Future<Map<String, String>?> loadSavedCredentials() {
    return _repository.getSavedCredentials();
  }

  /// Reset password.
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _repository.resetPassword(email);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout user.
  Future<void> logout() async {
    _setLoading(true);
    await _repository.logout();
    _user = null;
    _isLoggedIn = false;
    _setLoading(false);
  }

  /// Update user profile.
  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_user == null) return;
    await _repository.updateProfile(_user!.uid, data);
    _user = await _repository.getUserProfile(_user!.uid);
    notifyListeners();
  }

  /// Complete onboarding.
  Future<void> completeOnboarding() async {
    await _repository.completeOnboarding();
    _onboardingComplete = true;
    notifyListeners();
  }

  /// Delete user account.
  Future<void> deleteAccount(String uid) async {
    _setLoading(true);
    try {
      await _repository.deleteAccount(uid);
      _user = null;
      _isLoggedIn = false;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Clear error.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  bool _isGuestMode = false;
  String? _errorMessage;
  String? _userAvatarUrl;

  // Getters
  bool get isLoading => _isLoading;
  bool get isGuestMode => _isGuestMode;
  String? get errorMessage => _errorMessage;
  String? get userAvatarUrl => _userAvatarUrl;
  User? get currentUser => _supabase.auth.currentUser;

  // Authenticated state check
  bool get isAuthenticated => currentUser != null && !_isGuestMode;

  AuthViewModel() {
    // Supabase Auth State Listener
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        _isGuestMode = false;
      }
      loadUserAvatar();
    });
    loadUserAvatar();
  }

  // Profile Avatar Load Logic
  Future<void> loadUserAvatar() async {
    if (_isGuestMode) {
      final box = await Hive.openBox('settingsBox');
      _userAvatarUrl = box.get('guest_profile_image');
    } else {
      final user = currentUser;
      _userAvatarUrl = user?.userMetadata?['avatar_url']?.toString();
    }
    notifyListeners();
  }

  // Avatar Update Logic across App
  Future<void> updateAvatarUrl(String url) async {
    _userAvatarUrl = url;
    notifyListeners();
  }

  // 1. Email & Password Sign In
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (response.user != null) {
        _isGuestMode = false;
        await loadUserAvatar();
        notifyListeners();
        return true;
      }
      return false;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = "An unexpected error occurred during sign in.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 2. Email & Password Sign Up
  Future<bool> signUp(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );
      if (response.user != null) {
        _isGuestMode = false;
        await loadUserAvatar();
        notifyListeners();
        return true;
      }
      return false;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = "Sign up failed. Please try again.";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 3. Google Sign-In (Direct Supabase OAuth Flow)
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final bool response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.flavora://login-callback/',
      );

      if (response) {
        _isGuestMode = false;
        await loadUserAvatar();
        notifyListeners();
        return true;
      }
      return false;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = "Google Sign-In failed: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }


  // Reset Password via Email
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _supabase.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: kIsWeb ? null : 'io.supabase.flavora://reset-callback/',
      );
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = "Failed to send reset link: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 4. Guest Mode Toggle
  void continueAsGuest() {
    _isGuestMode = true;
    _errorMessage = null;
    loadUserAvatar();
  }

  // 5. Sign Out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _supabase.auth.signOut();
      _isGuestMode = false;
      _userAvatarUrl = null;
    } catch (e) {
      _errorMessage = "Sign out error: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  // Reset Error Message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Private Loading Helper
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
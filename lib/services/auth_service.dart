// lib/services/auth_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import '../models/user.dart' as app_models;

class AuthService {
  // Singleton Pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  // --- 1. Supabase Authentication ---

  User? get currentSupabaseUser => _supabase.auth.currentUser;

  /// Sign Up
  Future<AuthResponse> signUp(String email, String password, String fullName) async {
    try {
      // Pass full_name in metadata so the Trigger can pick it up
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Google Signin
  Future<bool> signInWithGoogle() async {
    try {
      // REPLACE 'io.supabase.edudoc' with your actual app package name if different
      return await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.edudoc://login-callback',
      );
    } catch (e) {
      rethrow;
    }
  }
  /// Sign In
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// ✅ ADD THIS METHOD (Fixes the error)
  Future<AuthResponse> verifyEmailOtp(String email, String token) async {
    try {
      return await _supabase.auth.verifyOTP(
        token: token,
        type: OtpType.signup,
        email: email,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Fetch User Profile
  Future<app_models.User?> fetchUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        return app_models.User(
          id: user.id,
          email: user.email ?? '',
          fullName: data['full_name'] ?? '',
          phoneNumber: data['phone_number'] ?? '',
          bio: data['bio'] ?? '',
          profileImageBase64: null,
        );
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }

    // Fallback if DB fetch fails
    return app_models.User(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] ?? 'User',
      phoneNumber: '',
      bio: '',
      profileImageBase64: null,
    );
  }

  // --- 2. Secure Storage (PINs) ---

  Future<void> saveUserPin(String pin) async {
    await _secureStorage.write(key: 'user_pin', value: pin);
  }

  Future<bool> verifyPin(String inputPin) async {
    String? storedPin = await _secureStorage.read(key: 'user_pin');
    return storedPin != null ? storedPin == inputPin : inputPin == '1234';
  }

  // --- 3. Biometrics ---

  Future<bool> get isBiometricsAvailable async {
    try {
      final bool canCheck = await _localAuth.canCheckBiometrics;
      final bool isSupported = await _localAuth.isDeviceSupported();
      return canCheck || isSupported;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final isAvailable = await isBiometricsAvailable;
      if (!isAvailable) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access EduDoc',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (_) {
      return false;
    }
  }
}
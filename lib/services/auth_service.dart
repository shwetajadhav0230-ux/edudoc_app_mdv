// lib/services/auth_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import '../models/user.dart' as app_models;
import '../utils/constants.dart'; // Added
import 'data_service.dart'; // Added

class AuthService {
  // Singleton Pattern
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  // ✅ Added: Lazy initialization for logging service
  late final DataService _dataService = DataService();

  // --- 1. Supabase Authentication ---

  User? get currentSupabaseUser => _supabase.auth.currentUser;

  Future<AuthResponse> signUp(String email, String password,
      String fullName) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      // ✅ Added: Log User Creation
      if (response.user != null) {
        await _dataService.logActivity(
          action: AppActions.userCreated,
          entityType: EntityTypes.users,
          description: 'New user registered: $email',
        );
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      // Calls the Edge Function we just deployed
      final response = await _supabase.functions.invoke('delete-account');

      if (response.status != 200) {
        throw "Failed to delete account. Please try again.";
      }

      // If successful, sign out locally
      await signOut();
    } catch (e) {
      debugPrint("Error deleting account: $e");
      rethrow;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      return await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.edudoc://login-callback',
      );
    } catch (e) {
      rethrow;
    }
  }

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

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// ✅ UPDATED: Fetch User Profile matching new schema
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
        return app_models.User.fromMap(data);
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
      profileImageUrl: user.userMetadata?['avatar_url'] ??
          user.userMetadata?['profile_image_url'],
    );
  }

  /// ✅ UPDATED: Update User Profile in Supabase
  /// Only updates fields that exist in your database table.
  Future<void> updateUserProfile(app_models.User user) async {
    // 1. Fetch old data for logging comparison
    final oldData = await _supabase.from('users').select().eq('id', user.id).maybeSingle();

    final updates = {
      'full_name': user.fullName,
      'phone_num': user.phoneNumber,
      'profile_image_url': user.profileImageUrl, // Matches your DB column
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      await _supabase.from('users').upsert({
        'id': user.id,
        ...updates,
      });

      // 2. Log activity with old vs new data
      await _dataService.logActivity(
        action: AppActions.profileUpdated,
        entityType: EntityTypes.users,
        description: 'User updated profile information',
        oldData: oldData,
        newData: updates,
        // Save profile pic as cover_url
      );

    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  // --- 2. Secure Storage (PINs) ---

  Future<void> saveUserPin(String pin) async {
    await _secureStorage.write(key: 'user_pin', value: pin);
  }

  Future<bool> verifyPin(String inputPin) async {
    String? storedPin = await _secureStorage.read(key: 'user_pin');
    return storedPin != null && storedPin == inputPin;
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

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint("Error fetching biometrics: $e");
      return <BiometricType>[];
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

  Future<bool> verifyCurrentPassword(String password) async {
    final user = _supabase.auth.currentUser;
    if (user == null || user.email == null) return false;

    try {
      // Attempt to sign in with the current email and the provided password
      final response = await _supabase.auth.signInWithPassword(
        email: user.email!,
        password: password,
      );

      // If the session is not null, the password is correct
      return response.session != null;
    } catch (e) {
      debugPrint('Password verification failed: $e');
      return false;
    }
  }
}
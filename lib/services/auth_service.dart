import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  // Singleton Pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  // --- 1. Secure Storage (Tokens & PINs) ---

  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<void> saveUserPin(String pin) async {
    await _secureStorage.write(key: 'user_pin', value: pin);
  }

  Future<bool> verifyPin(String inputPin) async {
    String? storedPin = await _secureStorage.read(key: 'user_pin');
    // Fallback to default '1234' if no PIN is set yet
    return storedPin != null ? storedPin == inputPin : inputPin == '1234';
  }

  // --- 2. Biometric Authentication ---

  Future<bool> get isBiometricsAvailable async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
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

  // --- 3. Session Persistence (User Data) ---

  Future<void> saveUserSession(User user) async {
    final prefs = await SharedPreferences.getInstance();
    // Serialize User object to JSON string
    // Note: Ensure your User model has toJson()
    String userJson = jsonEncode({
      'id': user.id,
      'fullName': user.fullName,
      'email': user.email,
      'phoneNumber': user.phoneNumber,
      'bio': user.bio,
      // Add other fields as needed
    });
    await prefs.setString('user_session', userJson);
    await prefs.setBool('is_logged_in', true);
  }

  Future<User?> loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('is_logged_in') ?? false) {
      String? userStr = prefs.getString('user_session');
      if (userStr != null) {
        Map<String, dynamic> userMap = jsonDecode(userStr);
        return User(
          id: userMap['id'],
          fullName: userMap['fullName'],
          email: userMap['email'],
          phoneNumber: userMap['phoneNumber'],
          bio: userMap['bio'],
          profileImageBase64: null, // Images usually re-fetched or cached separately
        );
      }
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears SharedPreferences (Theme, User Data)
    await _secureStorage.deleteAll(); // Clears Secure Tokens
  }
}
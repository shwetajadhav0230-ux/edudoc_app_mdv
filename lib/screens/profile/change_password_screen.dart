// lib/screens/profile/change_password_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart'; // Import AppState

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // --- Utility Function: Handle Password Update ---
  void _handleChangePassword(AppState appState, BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // 1. Retrieve text inputs
      final currentPassword = _currentPasswordController.text;
      final newPassword = _newPasswordController.text;

      // 2. Simulate validation against the current correct PIN (from AppState)
      if (currentPassword != appState.correctPin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Current password/PIN is incorrect.'),
          ),
        );
        return;
      }

      // 3. (In a real app: update backend credentials)

      // 4. Provide success feedback and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );

      // Clear fields and navigate back to settings
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      appState.navigateBack();
    }
  }

  // --- Validation Functions ---
  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your current password/PIN.';
    }
    // Assume PIN must be 4 characters for validation consistency
    if (value.length != 4) {
      return 'Current password must be 4 characters.';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.length < 4) {
      return 'New password must be at least 4 characters long.';
    }
    if (value == _currentPasswordController.text) {
      return 'New password cannot be the same as the old one.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _newPasswordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read the AppState for navigation/constants, but don't listen
    final appState = Provider.of<AppState>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // VITAL: Back button linked to the AppState navigation logic
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.navigateBack(),
        ),
        title: const Text('Change Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Security', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),

              // --- 1. Current Password Field ---
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: 'Current Password / PIN',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: _validateCurrentPassword,
              ),

              const SizedBox(height: 24),

              // --- 2. New Password Field ---
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(Icons.vpn_key_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: _validateNewPassword,
              ),

              const SizedBox(height: 16),

              // --- 3. Confirm New Password Field ---
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: const Icon(Icons.check_circle_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: _validateConfirmPassword,
              ),

              const SizedBox(height: 32),

              // --- Save Button ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleChangePassword(appState, context),
                  icon: const Icon(Icons.save),
                  label: const Text('Update Password'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

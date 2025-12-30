// lib/screens/profile/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../state/app_state.dart';
import '../../services/auth_service.dart';
import 'package:local_auth/local_auth.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => appState.navigateBack(),
        ),
        title: const Text(
            'Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionHeader(theme, 'ACCOUNT'),
          _buildSettingsGroup(isDark, [
            _buildSettingTile(
              context,
              icon: Icons.person_outline,
              color: Colors.blue,
              title: 'Edit Profile',
              onTap: () => appState.navigate(AppScreen.profileEdit),
            ),
            _buildSettingTile(
              context,
              icon: Icons.email_outlined,
              color: Colors.orange,
              title: 'Email Management',
              subtitle: appState.currentUser.email,
              onTap: () => appState.navigate(AppScreen.emailManagement),
            ),
          ]),

          _buildSectionHeader(theme, 'SECURITY'),
          _buildSettingsGroup(isDark, [
            _buildSettingTile(
              context,
              icon: Icons.pin_outlined,
              color: Colors.indigo,
              title: appState.isTransactionPinSet
                  ? 'Update Transaction PIN'
                  : 'Set Transaction PIN',
              subtitle: 'Secure your cart purchases',
              onTap: () => _showSetPinDialog(context, appState),
            ),
            _buildSettingTile(
              context,
              icon: Icons.app_registration,
              color: Colors.green,
              title: 'Set App Unlock PIN',
              subtitle: 'Create a 4-digit code to protect app entry',
              onTap: () => _showSetAppUnlockPinDialog(context, appState),
            ),
            _buildSettingTile(
              context,
              icon: Icons.lock_reset_outlined,
              color: Colors.teal,
              title: 'Forgot Password?',
              subtitle: 'Send reset link to email',
              onTap: () async {
                try {
                  await Supabase.instance.client.auth.resetPasswordForEmail(
                      appState.currentUser.email);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Reset link sent to your email!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              },
            ),

            // DYNAMIC BIOMETRIC TOGGLE
            // Using FutureBuilder to handle the async biometric check safely
            FutureBuilder<List<BiometricType>>(
              future: appState.enrolledBiometrics,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox
                      .shrink(); // Hide if no biometrics are enrolled
                }

                final available = snapshot.data!;
                IconData bioIcon = Icons.fingerprint;
                String bioTitle = 'Biometric Login';

                if (available.contains(BiometricType.face)) {
                  bioIcon = Icons.face;
                  bioTitle = 'Face ID Login';
                }

                return _buildToggleTile(
                  icon: bioIcon,
                  color: Colors.purple,
                  title: bioTitle,
                  value: appState.isBiometricEnabled,
                  onChanged: (val) => appState.updateBiometricPreference(val),
                );
              },
            ),
          ]),

          _buildSectionHeader(theme, 'PREFERENCES'),
          _buildSettingsGroup(isDark, [
            _buildToggleTile(
              icon: appState.isDarkTheme ? Icons.dark_mode : Icons.light_mode,
              color: Colors.amber,
              title: 'Dark Mode',
              value: appState.isDarkTheme,
              onChanged: (_) => appState.toggleTheme(),
            ),
            _buildToggleTile(
              icon: Icons.notifications_none,
              color: Colors.redAccent,
              title: 'Push Notifications',
              value: appState.areNotificationsEnabled,
              onChanged: (val) => appState.toggleAppNotifications(val),
            ),
          ]),

          _buildSectionHeader(theme, 'DANGER ZONE'),
          _buildSettingsGroup(isDark, [
            _buildSettingTile(
              context,
              icon: Icons.delete_outline,
              color: Colors.red,
              title: 'Delete Account',
              titleColor: Colors.red,
              onTap: () => _confirmDelete(context, appState),
            ),
          ]),

          const SizedBox(height: 40),
          Center(
            child: Text(
              'EduDoc Version 1.0.4',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 8, top: 24),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.primary.withOpacity(0.7),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black
            .withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black
              .withOpacity(0.05),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.w600, color: titleColor, fontSize: 15),
      ),
      subtitle: subtitle != null ? Text(
          subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: const Icon(
          Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required Color color,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: color,
      ),
    );
  }

  // --- ACTIONS ---

  void _showSetAppUnlockPinDialog(BuildContext context, AppState appState) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text('Set App Unlock PIN'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Create a PIN to secure the app when it opens.'),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24,
                      letterSpacing: 10,
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '0000',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    counterText: "",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (controller.text.length == 4) {
                    await appState.updateUserPin(controller.text);
                    if (context.mounted) Navigator.pop(context);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('App Unlock PIN set successfully!')),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showSetPinDialog(BuildContext context, AppState appState) {
    final pinController = TextEditingController();
    final passwordController = TextEditingController();
    final isReset = appState.isTransactionPinSet;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isReset ? 'Reset Transaction PIN' : 'Set Transaction PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isReset) ...[
              const Text('Enter your account password to authorize the reset:'),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Account Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
            ],
            const Text('Enter a new 4-digit PIN:'),
            const SizedBox(height: 10),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 10, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '0000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                counterText: "",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (pinController.text.length == 4) {
                if (isReset) {
                  await appState.resetTransactionPin(
                      passwordController.text,
                      pinController.text,
                      context
                  );
                } else {
                  await appState.setTransactionPin(pinController.text);
                }
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save PIN'),
          ),
        ],
      ),
    );
  }

  // lib/screens/profile/settings_screen.dart

  Future<void> _confirmDelete(BuildContext context, AppState appState) async {
    final passwordController = TextEditingController();

    // 1. Initial Confirmation Dialog
    final bool? confirmStage1 = await showDialog<bool>(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            title: const Text('Delete Account?'),
            content: const Text(
              'This action is permanent.\nAll your data, wallet balance, and purchased books will be lost forever.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('DELETE', style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
    );

    if (confirmStage1 != true || !context.mounted) return;

    // 2. Re-authentication Challenge
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            title: const Text('Verify Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                    'Please enter your password to confirm account deletion.'),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  final password = passwordController.text.trim();
                  if (password.isNotEmpty) {
                    Navigator.pop(ctx); // Close dialog
                    appState.requestAccountDeletion(password, context);
                  }
                },
                child: const Text(
                    'Confirm Deletion', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }
}
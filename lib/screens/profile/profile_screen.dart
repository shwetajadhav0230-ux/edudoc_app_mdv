// lib/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../state/app_state.dart';
import 'downloads_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final user = appState.currentUser;
    final isDark = theme.brightness == Brightness.dark;

    Widget profileAvatar;
    if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) {
      profileAvatar = CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(user.profileImageUrl!),
        onBackgroundImageError: (_, __) {},
      );
    } else {
      profileAvatar = CircleAvatar(
        radius: 30,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Icon(Icons.person, color: theme.colorScheme.primary, size: 30),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('My Account', style: theme.textTheme.titleLarge),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Profile Details Card ---
            Card(
              child: ListTile(
                leading: profileAvatar,
                title: Text(
                  user.fullName.isNotEmpty ? user.fullName : 'No Name',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text(user.email),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => appState.navigate(AppScreen.profileEdit),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // --- 2. Activity & Library ---
            _sectionHeader(theme, 'ACTIVITY'),
            _settingsGroup(isDark, [
              _tile(
                icon: Icons.show_chart,
                color: theme.colorScheme.primary,
                title: 'My Purchases & Downloads',
                onTap: () => appState.navigate(AppScreen.userActivity),
              ),
              _tile(
                icon: Icons.download_done_rounded,
                color: Colors.indigo,
                title: 'Offline Library',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DownloadsScreen()),
                ),
              ),
            ]),

            const SizedBox(height: 16),

            // --- 3. Account Settings ---
            _sectionHeader(theme, 'ACCOUNT'),
            _settingsGroup(isDark, [
              _tile(
                icon: Icons.email_outlined,
                color: Colors.orange,
                title: 'Email Management',
                subtitle: user.email,
                onTap: () => appState.navigate(AppScreen.emailManagement),
              ),
              _tile(
                icon: Icons.lock_outline,
                color: Colors.blue,
                title: 'Change Password',
                onTap: () => appState.navigate(AppScreen.changePassword),
              ),
            ]),

            const SizedBox(height: 16),

            // --- 4. Security ---
            _sectionHeader(theme, 'SECURITY'),
            _settingsGroup(isDark, [
              _tile(
                icon: Icons.pin_outlined,
                color: Colors.indigo,
                title: appState.isTransactionPinSet
                    ? 'Update Transaction PIN'
                    : 'Set Transaction PIN',
                subtitle: 'Secure your cart purchases',
                onTap: () => _showSetPinDialog(context, appState),
              ),
              _tile(
                icon: Icons.app_registration,
                color: Colors.green,
                title: 'Set App Unlock PIN',
                subtitle: 'Create a 4-digit code to protect app entry',
                onTap: () => _showSetAppUnlockPinDialog(context, appState),
              ),
              _toggleTile(
                icon: Icons.phonelink_lock,
                color: Colors.deepPurple,
                title: 'Enable App Lock',
                value: appState.isAppLockEnabled,
                onChanged: (val) => appState.toggleAppLock(val),
              ),
              _tile(
                icon: Icons.lock_reset_outlined,
                color: Colors.teal,
                title: 'Forgot Password?',
                subtitle: 'Send reset link to email',
                onTap: () async {
                  try {
                    await Supabase.instance.client.auth
                        .resetPasswordForEmail(user.email);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Reset link sent to your email!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red),
                      );
                    }
                  }
                },
              ),
              FutureBuilder<List<BiometricType>>(
                future: appState.enrolledBiometrics,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final available = snapshot.data!;
                  final bioIcon = available.contains(BiometricType.face)
                      ? Icons.face
                      : Icons.fingerprint;
                  final bioTitle = available.contains(BiometricType.face)
                      ? 'Face ID Login'
                      : 'Biometric Login';
                  return _toggleTile(
                    icon: bioIcon,
                    color: Colors.purple,
                    title: bioTitle,
                    value: appState.isBiometricEnabled,
                    onChanged: (val) => appState.updateBiometricPreference(val),
                  );
                },
              ),
            ]),

            const SizedBox(height: 16),

            // --- 5. Preferences ---
            _sectionHeader(theme, 'PREFERENCES'),
            _settingsGroup(isDark, [
              _toggleTile(
                icon: appState.isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                color: Colors.amber,
                title: 'Dark Mode',
                value: appState.isDarkTheme,
                onChanged: (_) => appState.toggleTheme(),
              ),
              _toggleTile(
                icon: Icons.notifications_none,
                color: Colors.redAccent,
                title: 'Push Notifications',
                value: appState.areNotificationsEnabled,
                onChanged: (val) => appState.toggleAppNotifications(val),
              ),
            ]),

            const SizedBox(height: 16),

            // --- 6. About ---
            _sectionHeader(theme, 'INFO'),
            _settingsGroup(isDark, [
              _tile(
                icon: Icons.info_outline,
                color: Colors.blueGrey,
                title: 'About EduDoc',
                onTap: () => appState.navigate(AppScreen.about),
              ),
              _tile(
                icon: Icons.help_outline,
                color: Colors.cyan,
                title: 'Help & Support',
                onTap: () => appState.navigate(AppScreen.helpSupport),
              ),
            ]),

            const SizedBox(height: 16),

            // --- 7. Danger Zone ---
            _sectionHeader(theme, 'DANGER ZONE'),
            _settingsGroup(isDark, [
              _tile(
                icon: Icons.delete_outline,
                color: Colors.red,
                title: 'Delete Account',
                titleColor: Colors.red,
                onTap: () => _confirmDelete(context, appState),
              ),
            ]),

            const SizedBox(height: 20),

            // --- Logout Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => appState.logout(),
                icon: const Icon(Icons.logout, color: Colors.white),
                label:
                    const Text('Logout', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),

            const SizedBox(height: 16),
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
      ),
    );
  }

  // --- SHARED UI HELPERS ---

  Widget _sectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.primary.withOpacity(0.7),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _settingsGroup(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(children: children),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w600, color: titleColor, fontSize: 14)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 13, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required Color color,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: Switch.adaptive(
          value: value, onChanged: onChanged, activeColor: color),
    );
  }

  // --- DIALOGS ---

  void _showSetAppUnlockPinDialog(BuildContext context, AppState appState) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              style: const TextStyle(
                  fontSize: 24, letterSpacing: 10, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '0000',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.length == 4) {
                await appState.updateUserPin(controller.text);
                if (ctx.mounted) Navigator.pop(ctx);
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
      builder: (ctx) => AlertDialog(
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
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
              style: const TextStyle(
                  fontSize: 24, letterSpacing: 10, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '0000',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (pinController.text.length == 4) {
                if (isReset) {
                  await appState.resetTransactionPin(
                      passwordController.text, pinController.text, context);
                } else {
                  await appState.setTransactionPin(pinController.text);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save PIN'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AppState appState) async {
    final passwordController = TextEditingController();

    final bool? confirmStage1 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action is permanent.\nAll your data, wallet balance, and purchased books will be lost forever.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmStage1 != true || !context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verify Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your password to confirm account deletion.'),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final password = passwordController.text.trim();
              if (password.isNotEmpty) {
                Navigator.pop(ctx);
                appState.requestAccountDeletion(password, context);
              }
            },
            child: const Text('Confirm Deletion',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

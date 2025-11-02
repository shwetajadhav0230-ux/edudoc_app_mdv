import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.security, color: theme.colorScheme.tertiary, size: 64),
              const SizedBox(height: 16),
              Text(
                'App Permissions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 32,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Column(
                  children: const [
                    PermissionTile(
                      icon: Icons.folder,
                      title: 'Storage Access',
                      description: 'Save downloaded documents',
                      enabled: false,
                    ),
                    PermissionTile(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      description: 'Receive updates and offers',
                      enabled: true,
                    ),
                    PermissionTile(
                      icon: Icons.camera_alt,
                      title: 'Camera Access',
                      description: 'Scan QR codes',
                      enabled: false,
                    ),
                    PermissionTile(
                      icon: Icons.fingerprint,
                      title: 'Biometric Auth',
                      description: 'Use fingerprint/face ID',
                      enabled: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => appState.navigate(AppScreen.lockUnlock),
                  child: const Text(
                    'Continue',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => appState.navigate(AppScreen.home),
                child: Text(
                  'Skip for Now (Prototype Mode)',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool enabled;

  const PermissionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: Icon(
          icon,
          color: enabled
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: enabled
                ? theme.colorScheme.onSurface
                : theme.colorScheme.outline,
          ),
        ),
        subtitle: Text(description, style: theme.textTheme.bodySmall),
        trailing: Icon(
          enabled ? Icons.check_circle : Icons.cancel,
          color: enabled ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}

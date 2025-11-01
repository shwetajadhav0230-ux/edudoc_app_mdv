import 'package:flutter/material.dart';

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

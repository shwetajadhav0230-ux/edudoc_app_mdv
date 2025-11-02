import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart'; // Ensure correct path to AppState

class ProfileAvatar extends StatelessWidget {
  final VoidCallback onTap;
  const ProfileAvatar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen only to changes in the AppState's User object
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final user = appState.currentUser;
        final theme = Theme.of(context);

        Widget avatarWidget;

        if (user.profileImageBase64 != null &&
            user.profileImageBase64!.isNotEmpty) {
          // Display image from Base64 string
          try {
            final imageBytes = base64Decode(user.profileImageBase64!);
            avatarWidget = CircleAvatar(
              backgroundImage: MemoryImage(imageBytes),
              radius: 16,
            );
          } catch (e) {
            // Fallback if Base64 decoding fails
            avatarWidget = CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.7),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
              radius: 16,
            );
          }
        } else {
          // Display default icon placeholder
          avatarWidget = CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.7),
            child: const Icon(Icons.person, color: Colors.white, size: 16),
            radius: 16,
          );
        }

        return GestureDetector(onTap: onTap, child: avatarWidget);
      },
    );
  }
}

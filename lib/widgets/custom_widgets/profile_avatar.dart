import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart'; // Assuming AppState path is correct

class ProfileAvatar extends StatelessWidget {
  final VoidCallback onTap;
  const ProfileAvatar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen for profile image changes without rebuilding the whole AppBar
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final user = appState.currentUser;
        final theme = Theme.of(context);

        // Determine if we have a base64 image string to display
        final String? base64Image = user.profileImageBase64;

        Widget avatarWidget;

        // Default radius is 20 for the AppBar context
        const double radius = 20;

        if (base64Image != null && base64Image.isNotEmpty) {
          // Display the selected/saved image
          // FIX: Added error handling in case base64 string is invalid
          try {
            final imageBytes = base64Decode(base64Image);
            avatarWidget = CircleAvatar(
              radius: radius,
              backgroundImage: MemoryImage(imageBytes),
            );
          } catch (e) {
            // Fallback to default icon on decode error
            avatarWidget = CircleAvatar(
              radius: radius,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.7),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            );
          }
        } else {
          // Default icon avatar
          avatarWidget = CircleAvatar(
            radius: radius,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.7),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          );
        }

        return GestureDetector(onTap: onTap, child: avatarWidget);
      },
    );
  }
}

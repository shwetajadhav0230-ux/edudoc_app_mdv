import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

class ProfileAvatar extends StatelessWidget {
  final VoidCallback onTap;
  const ProfileAvatar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final user = appState.currentUser;
        final theme = Theme.of(context);

        ImageProvider? imageProvider;

        if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) {
          if (user.profileImageUrl!.startsWith('http')) {
            // ✅ CASE 1: It's a URL (Supabase Storage)
            imageProvider = NetworkImage(user.profileImageUrl!);
          } else {
            // ✅ CASE 2: It's a Base64 string (Legacy/Local)
            try {
              final imageBytes = base64Decode(user.profileImageUrl!);
              imageProvider = MemoryImage(imageBytes);
            } catch (e) {
              // Invalid format
              imageProvider = null;
            }
          }
        }

        return GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 18, // Slightly larger for better visibility
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? Icon(Icons.person, color: theme.colorScheme.primary, size: 20)
                : null,
          ),
        );
      },
    );
  }
}
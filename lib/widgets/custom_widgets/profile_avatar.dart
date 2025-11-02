import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final VoidCallback onTap;
  const ProfileAvatar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const CircleAvatar(
        backgroundImage: AssetImage('assets/images/user.png'),
        radius: 16,
      ),
    );
  }
}

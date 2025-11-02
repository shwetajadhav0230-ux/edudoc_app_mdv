// lib/widgets/custom_widgets/cart_icon_badge.dart

import 'package:flutter/material.dart';

class CartIconWithBadge extends StatelessWidget {
  final int itemCount;
  final VoidCallback onTap;

  const CartIconWithBadge({
    super.key,
    required this.itemCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30), // For a circular splash effect
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Provides a larger tap area
        child: Stack(
          clipBehavior: Clip.none, // Allows the badge to render outside
          children: [
            // The cart icon itself
            Icon(
              Icons.shopping_cart_outlined,
              color: Colors.grey.shade400, // Matches your search icon color
            ),

            // The badge (only shown if items > 0)
            if (itemCount > 0)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary, // Pink notification color
                    shape: BoxShape.circle,
                    // This border creates a "punched-out" look against the app bar
                    border: Border.all(color: theme.colorScheme.surface.withAlpha(242), width: 2),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$itemCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
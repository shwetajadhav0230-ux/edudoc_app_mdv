// lib/widgets/custom_widgets/library_shelf_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';

class LibraryShelfCard extends StatelessWidget {
  final Product product;

  const LibraryShelfCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context, listen: false);

    return GestureDetector(
      onTap: () => appState.navigate(
        // FIX: Changed from AppScreen.reading to AppScreen.productDetails as requested.
        AppScreen.productDetails,
        id: product.id.toString(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. The Card (Image + Chip)
          // This Expanded widget makes the card fill the available
          // vertical space in the SizedBox from home_screen.dart
          Expanded(
            child: Card(
              clipBehavior: Clip.antiAlias, // Ensures image is clipped
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                fit: StackFit.expand, // Make stack fill the card
                children: [
                  // Image
                  _buildImage(theme),
                  // Type Chip (e.g., "Notes", "Books")
                  _buildTypeChip(theme),
                ],
              ),
            ),
          ),

          // 2. The Title below the card
          const SizedBox(height: 8),
          Text(
            product.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- Builder Methods ---

  Widget _buildImage(ThemeData theme) {
    if (product.imageUrl.isEmpty) {
      return _buildPlaceholder(theme);
    }
    // Use the product's image URL
    return Image.network(
      product.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder(theme);
      },
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    IconData typeIcon = Icons.article_outlined;
    if (product.type == 'Books') {
      typeIcon = Icons.book_outlined;
    } else if (product.type == 'Journals') {
      typeIcon = Icons.edit_note;
    }
    // A simple placeholder if no image is available
    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
      child: Center(
        child: Icon(
          typeIcon,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant.withAlpha(179),
        ),
      ),
    );
  }

  Widget _buildTypeChip(ThemeData theme) {
    // This is the "Notes" or "Books" chip
    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        decoration: BoxDecoration(
          // Semi-transparent black, as seen in the image
          color: Colors.black.withAlpha(153),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          product.type,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
// lib/widgets/custom_widgets/product_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context, listen: false);

    // 1. ADD THIS LINE TO CHECK THE THEME
    final isLightMode = theme.brightness == Brightness.light;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withAlpha(26),

      // 2. MODIFY THE 'shape' PROPERTY
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // ADD THIS 'side' PROPERTY
        side: isLightMode
            ? BorderSide(color: Colors.grey.shade300, width: 1) // Border for light mode
            : BorderSide.none, // No border for dark mode
      ),
      child: InkWell(
        onTap: onTap ??
                () => appState.navigate(AppScreen.productDetails,
                id: product.id.toString()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // MODIFICATION: This ensures the Column doesn't stretch vertically
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- 1. Image, Type Chip, and Rating Section ---
            Stack(
              children: [
                _buildImage(theme), // Updated with placeholder
                _buildTypeChip(theme), // Updated to new pill style
                _buildRating(theme), // Moved to the Stack
              ],
            ),

            // --- 2. Content Section ---
            // MODIFICATION: Removed the 'Expanded' widget
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // --- Top Content Group ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTitle(theme),
                      const SizedBox(height: 4),
                      _buildAuthor(theme),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // --- Bottom Action Row ---
                  _buildBottomActionRow(theme, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Builder Methods ---
  // (All builder methods below are unchanged)

  Widget _buildImage(ThemeData theme) {
    if (product.imageUrl.isEmpty) {
      return _buildPlaceholder(theme);
    }

    return Image.network(
      product.imageUrl,
      height: 100,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        return progress == null
            ? child
            : Container(
          height: 100,
          color: theme.cardColor,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder(theme);
      },
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    IconData typeIcon = Icons.article_outlined; // Default
    if (product.type == 'Books') {
      typeIcon = Icons.book_outlined;
    } else if (product.type == 'Journals') {
      typeIcon = Icons.edit_note;
    }

    return Container(
      height: 100,
      width: double.infinity,
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
    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        decoration: BoxDecoration(
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

  Widget _buildRating(ThemeData theme) {
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(153), // Dark background for contrast
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Ensure the row takes minimum space
          children: [
            Icon(Icons.star_rounded, color: Colors.amber, size: 16), // Smaller star
            const SizedBox(width: 4),
            Text(
              product.rating.toString(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text for contrast
              ),
            ),
            Text(
              ' (${product.reviewCount})', // Only show count, not "reviews"
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white.withAlpha(204), // Slightly subdued white
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      product.title,
      style: theme.textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAuthor(ThemeData theme) {
    return Text(
      'by ${product.author}',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.textTheme.bodySmall?.color?.withAlpha(179),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBottomActionRow(ThemeData theme, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildPriceInfo(theme),
        Row(
          children: [
            const SizedBox(width: 8),
            _buildBookmarkButton(theme, context),
          ],
        )
      ],
    );
  }

  Widget _buildPriceInfo(ThemeData theme) {
    if (product.isFree) {
      return Text(
        'FREE',
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.tertiary,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Row(
      children: [
        Icon(
          Icons.monetization_on_rounded,
          color: Colors.amber.shade700,
          size: 22,
        ),
        const SizedBox(width: 6),
        Text(
          product.price.toString(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildBookmarkButton(ThemeData theme, BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isBookmarked =
        appState.bookmarkedProductIds.contains(product.id);

        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              appState.toggleBookmark(product.id);
            },
            child: Icon(
              isBookmarked ? Icons.bookmark_added_rounded : Icons.bookmark_rounded,
              color: isBookmarked
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.onSurface.withAlpha(179),
              size: 22,
            ),
          ),
        );
      },
    );
  }
}
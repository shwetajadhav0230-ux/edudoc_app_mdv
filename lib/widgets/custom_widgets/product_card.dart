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
    // Use listen: false as we only need to access methods, not rebuild the whole card
    final appState = Provider.of<AppState>(context, listen: false);

    IconData typeIcon = Icons.article; // Default
    if (product.type == 'Books') {
      typeIcon = Icons.book_outlined;
    } else if (product.type == 'Journals') {
      typeIcon = Icons.edit_note;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap:
            onTap ??
            () => appState.navigate(
              AppScreen.productDetails,
              id: product.id.toString(),
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Image and Type Chip Section ---
            Stack(children: [_buildImage(theme), _buildTypeChip(theme)]),
            // --- 2. Content Section ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(theme),
                    const SizedBox(height: 4),
                    _buildAuthor(theme),
                    const SizedBox(height: 5),
                    _buildRating(theme),

                    // Spacer pushes the new action row to the bottom
                    const Spacer(),

                    // --- 3. Bottom Action Row ---
                    _buildBottomActionRow(
                      theme,
                      context,
                      appState,
                    ), // Pass appState
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Builder Methods (Unchanged image/text helpers) ---

  Widget _buildImage(ThemeData theme) {
    // Check if the URL is null or empty
    if (product.imageUrl == null || product.imageUrl.isEmpty) {
      return _buildPlaceholder(theme); // Show placeholder
    }

    return Image.network(
      product.imageUrl,
      height: 190,
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
      // Show placeholder on error
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

    return Container(
      height: 100,
      width: double.infinity,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      child: Center(
        child: Icon(
          typeIcon,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
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
          color: Colors.black.withOpacity(0.6),
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

  Widget _buildTitle(ThemeData theme) {
    return Text(
      product.title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAuthor(ThemeData theme) {
    return Text(
      'by ${product.author}',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRating(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.star_rounded, color: Colors.amber, size: 20),
        const SizedBox(width: 4),
        Text(
          product.rating.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Flexible(
          child: Text(
            ' (${product.reviewCount} reviews)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // --- NEW: Bottom Row Widget ---

  Widget _buildBottomActionRow(
    ThemeData theme,
    BuildContext context,
    AppState appState,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Price
        _buildPriceInfo(theme),
        // 2. Buttons
        Row(
          children: [
            _buildCartButton(
              theme,
              appState,
              context,
            ), // Passed context/appState
            const SizedBox(width: 8),
            _buildBookmarkButton(
              theme,
              appState,
              context,
            ), // Passed context/appState
          ],
        ),
      ],
    );
  }

  // NEW: Price display (Icon + Number)
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

  // NEW: Cart Button (Now functional)
  Widget _buildCartButton(
    ThemeData theme,
    AppState appState,
    BuildContext context,
  ) {
    // Only show cart button if item is purchasable (not free and not subscription based, though free items are implicitly added via cart)
    // For simplicity, we make the button clickable only if the item is not free.
    // If it's free, the main card tap/action button handles acquisition.
    // However, your request implies this button should work for all actions.

    // We only show the Cart button if the item costs money, otherwise the user should tap the card for download.
    if (product.isFree) return const SizedBox.shrink();

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary, // Using primary color for cart
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          appState.addToCart(product);
          // Show Snackbar confirmation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.title} added to Cart.'),
              duration: const Duration(milliseconds: 1000),
            ),
          );
        },
        child: const Icon(
          Icons.shopping_cart_outlined,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  // NEW: Bookmark Button (Now functional and stateful)
  Widget _buildBookmarkButton(
    ThemeData theme,
    AppState appState,
    BuildContext context,
  ) {
    // We use a Consumer here so ONLY this icon rebuilds when bookmarks change, not the whole card.
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isBookmarked = appState.bookmarkedProductIds.contains(product.id);

        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            // Dark, theme-aware color
            color: theme.colorScheme.onSurface.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              appState.toggleBookmark(product.id);
              // Show Snackbar confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isBookmarked
                        ? '${product.title} removed from Wishlist.'
                        : '${product.title} added to Wishlist.',
                  ),
                  duration: const Duration(milliseconds: 1000),
                ),
              );
            },
            child: Icon(
              isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              // Use a striking color when bookmarked
              color: isBookmarked
                  ? theme
                        .colorScheme
                        .secondary // Pink accent
                  : theme.colorScheme.onSurface.withOpacity(0.7),
              size: 22,
            ),
          ),
        );
      },
    );
  }
}

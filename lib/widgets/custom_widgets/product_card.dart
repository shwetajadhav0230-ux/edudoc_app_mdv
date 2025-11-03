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

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap ??
                () => appState.navigate(AppScreen.productDetails,
                id: product.id.toString()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Image and Type Chip Section ---
            Stack(
              children: [
                _buildImage(theme), // Updated with placeholder
                _buildTypeChip(theme), // Updated to new pill style
                // Bookmark icon removed from here
              ],
            ),
            // --- 2. Content Section ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                // FIX: This is the Column from line 41
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // FIX: Use spaceBetween to push top/bottom content
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // --- Group top content together ---
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // Don't expand
                      children: [
                        _buildTitle(theme),
                        const SizedBox(height: 4),
                        _buildAuthor(theme),
                        const SizedBox(height: 5),
                        _buildRating(theme),
                      ],
                    ),

                    // const Spacer(), // <-- REMOVE this Spacer

                    // --- 3. New Bottom Action Row (replaces Price/Divider) ---
                    _buildBottomActionRow(theme, context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // --- Builder Methods ---

  Widget _buildImage(ThemeData theme) {
    // Check if the URL is null or empty
    if (product.imageUrl.isEmpty) {
      return _buildPlaceholder(theme); // Show placeholder
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
      // Show placeholder on error
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder(theme);
      },
    );
  }

  // NEW: Placeholder widget (as seen in your new image)
  Widget _buildPlaceholder(ThemeData theme) {
    IconData typeIcon = Icons.article_outlined; // Default
    if (product.type == 'Books') {
      typeIcon = Icons.book_outlined;
    } else if (product.type == 'Journals') {
      typeIcon = Icons.edit_note;
    }

    return Container(
      height: 100, // You can adjust this height
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

  // UPDATED: New "Notes" Pill Style
  Widget _buildTypeChip(ThemeData theme) {
    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        decoration: BoxDecoration(
          // Using a dark, semi-transparent color for visibility on any image
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16.0), // Pill shape
        ),
        child: Text(
          product.type,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Light text
          ),
        ),
      ),
    );
  }

  // --- Content Text (Unchanged) ---
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
          style:
          theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
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
  Widget _buildBottomActionRow(ThemeData theme, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Price
        _buildPriceInfo(theme),
        // 2. Buttons
        Row(
          children: [
            // MODIFICATION 1: Pass context to the cart button
            _buildCartButton(theme, context),
            const SizedBox(width: 8),
            _buildBookmarkButton(theme, context),
          ],
        )
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
          Icons.monetization_on_rounded, // Coin stack icon
          color: Colors.amber.shade700,
          size: 22,
        ),
        const SizedBox(width: 6),
        Text(
          product.price.toString(), // Just the number
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // NEW: Cart Button
  Widget _buildCartButton(ThemeData theme, BuildContext context) {
    // Using a simple Container + InkWell for perfect circle
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.purple.shade400, // Matching your image
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withAlpha(77),
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        // MODIFICATION 3: Implement the onTap logic
        onTap: () {
          // Get the AppState (listen: false because it's an action)
          final appState = Provider.of<AppState>(context, listen: false);

          // Call the addToCart method from app_state.dart
          appState.addToCart(product);

          // Show a confirmation snackbar
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
  // NEW: Bookmark Button
  Widget _buildBookmarkButton(ThemeData theme, BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isBookmarked =
        appState.bookmarkedProductIds.contains(product.id);

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
            },
            child: Icon(
              isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              // Use a striking color when bookmarked
              color: isBookmarked
                  ? Colors.pink.shade400
                  : theme.colorScheme.onSurface.withOpacity(0.7),
              size: 22,
            ),
          ),
        );
      },
    );
  }

// This method is no longer needed at the bottom
// Widget _buildPrice(ThemeData theme) { ... }

// This method is no longer needed in the stack
// Widget _buildBookmarkIcon() { ... }
}

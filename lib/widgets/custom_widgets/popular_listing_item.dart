// lib/widgets/custom_widgets/popular_listing_item.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';

class PopularListingItem extends StatelessWidget {
  final Product product;

  const PopularListingItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context, listen: false);

    // --- MODIFICATION: Image is now square, as in image_419d2b.png ---
    const double imageSize = 64.0;

    return InkWell(
      onTap: () => appState.navigate(AppScreen.productDetails,
          id: product.id.toString()),
      child: Card(
        // Using the card style from your new image
        elevation: 1,
        color: theme.cardColor, // Use the theme's card color
        shadowColor: theme.colorScheme.shadow.withAlpha(26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          // Internal padding
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: _buildImage(theme, imageSize, imageSize), // Pass new size
              ),
              const SizedBox(width: 12),

              // 2. Content Column
              Expanded(
                child: SizedBox(
                  height: imageSize, // Match image height
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        product.title,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Author
                      Text(
                        'by ${product.author}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                          theme.textTheme.bodySmall?.color?.withAlpha(179),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(), // Pushes buttons to the bottom
                      // Button Row
                      Row(
                        children: [
                          _buildCartButton(theme, context),
                          const SizedBox(width: 8),
                          _buildBookmarkButton(theme, context),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper methods for Image and Buttons ---

  Widget _buildImage(ThemeData theme, double height, double width) {
    if (product.imageUrl.isEmpty) {
      return _buildPlaceholder(theme, height, width);
    }
    return Image.network(
      product.imageUrl,
      height: height,
      width: width,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        return progress == null
            ? child
            : Container(
          height: height,
          width: width,
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
        return _buildPlaceholder(theme, height, width);
      },
    );
  }

  Widget _buildPlaceholder(ThemeData theme, double height, double width) {
    IconData typeIcon = Icons.article_outlined; // Default
    if (product.type == 'Books') {
      typeIcon = Icons.book_outlined;
    } else if (product.type == 'Journals') {
      typeIcon = Icons.edit_note;
    }
    return Container(
      height: height,
      width: width,
      color: theme.colorScheme.surfaceVariant.withAlpha(128),
      child: Center(
        child: Icon(
          typeIcon,
          size: 32,
          color: theme.colorScheme.onSurfaceVariant.withAlpha(179),
        ),
      ),
    );
  }

  // Cart button (matches the dark, rounded-square style)
  Widget _buildCartButton(ThemeData theme, BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        // Use a subtle background color
        color: theme.colorScheme.onSurface.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          final appState = Provider.of<AppState>(context, listen: false);
          appState.addToCart(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.title} added to Cart.'),
              duration: const Duration(milliseconds: 1000),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Icon(
          Icons.add_shopping_cart,
          // Use a theme-aware color
          color: theme.colorScheme.primary,
          size: 18,
        ),
      ),
    );
  }

  // Bookmark button
  Widget _buildBookmarkButton(ThemeData theme, BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isBookmarked =
        appState.bookmarkedProductIds.contains(product.id);
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: () {
              appState.toggleBookmark(product.id);
            },
            borderRadius: BorderRadius.circular(8),
            child: Icon(
              isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: isBookmarked
                  ? theme.colorScheme.secondary // Highlight when bookmarked
                  : theme.colorScheme.onSurface.withAlpha(179),
              size: 18,
            ),
          ),
        );
      },
    );
  }
}
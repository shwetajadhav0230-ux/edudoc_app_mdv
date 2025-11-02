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
                _buildImage(theme), // Height is 100px
                _buildTypeChip(theme),
                _buildRatingOnImage(theme), // Rating is on the image
              ],
            ),
            // --- 2. Content Section ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        // Rating is now on the image
                      ],
                    ),

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
    if (product.imageUrl.isEmpty) {
      return _buildPlaceholder(theme);
    }

    return Image.network(
      product.imageUrl,
      height: 130,
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
      height: 100, // Matching the image height
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
      child: Center(
        child: Icon(
          typeIcon,
          size: 30,
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

  Widget _buildRatingOnImage(ThemeData theme) {
    return Positioned(
      bottom: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          children: [
            Icon(Icons.star_rounded, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              product.rating.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
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
            // _buildCartButton(theme, context),
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
  //
  // Widget _buildCartButton(ThemeData theme, BuildContext context) {
  //   return Container(
  //     width: 35,
  //     height: 35,
  //     decoration: BoxDecoration(
  //       color: Colors.purple.shade400, // Matching your image
  //       shape: BoxShape.circle,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.purple.withAlpha(77),
  //           blurRadius: 8,
  //           offset: Offset(0, 4),
  //         )
  //       ],
  //     ),
  //     child: InkWell(
  //       borderRadius: BorderRadius.circular(20),
  //       onTap: () {
  //         final appState = Provider.of<AppState>(context, listen: false);
  //         appState.addToCart(product);
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('${product.title} added to Cart.'),
  //             duration: const Duration(milliseconds: 1000),
  //           ),
  //         );
  //       },
  //       child: const Icon(
  //         Icons.shopping_cart_outlined,
  //         color: Colors.white,
  //         size: 20,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildBookmarkButton(ThemeData theme, BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isBookmarked =
        appState.bookmarkedProductIds.contains(product.id);

        return Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
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
}
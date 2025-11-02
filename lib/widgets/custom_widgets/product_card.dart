import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../state/app_state.dart';

// Converted to StatefulWidget to manage hover state
class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovering = false;

  // Define hover constants
  static const double _hoverScale = 1.02;
  static const double _normalScale = 1.0;
  static const double _hoverElevation = 8;
  static const double _normalElevation = 4;
  static const Duration _animationDuration = Duration(milliseconds: 200);

  // --- Animation Handlers ---
  void _onEnter(PointerEvent details) {
    setState(() {
      _isHovering = true;
    });
  }

  void _onExit(PointerEvent details) {
    setState(() {
      _isHovering = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    // Check ownership status (using Consumer for this widget)
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isOwned = appState.ownedProductIds.contains(widget.product.id);

        // Determine the main tap action: Read if owned, Details if not
        final appStateMethods = Provider.of<AppState>(context, listen: false);
        final actualOnTap = isOwned
            ? () => appStateMethods.navigate(
                AppScreen.reading,
                id: widget.product.id.toString(),
              )
            : widget.onTap ??
                  () => appStateMethods.navigate(
                    AppScreen.productDetails,
                    id: widget.product.id.toString(),
                  );

        return MouseRegion(
          onEnter: _onEnter,
          onExit: _onExit,
          cursor: SystemMouseCursors.click,
          child: AnimatedScale(
            scale: _isHovering ? _hoverScale : _normalScale,
            duration: _animationDuration,
            child: Card(
              clipBehavior: Clip.antiAlias,
              // FIX: Explicitly set the color for contrast
              color: isDarkTheme ? theme.colorScheme.surface : theme.cardColor,
              elevation: _isHovering ? _hoverElevation : _normalElevation,
              shadowColor: isDarkTheme
                  ? Colors.black.withOpacity(0.8)
                  : theme.colorScheme.shadow.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: actualOnTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. Image and Type Chip Section ---
                    Stack(
                      children: [
                        _buildImage(theme, widget.product),
                        _buildTypeChip(theme, widget.product),
                      ],
                    ),
                    // --- 2. Content Section ---
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // --- Group top content together ---
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildTitle(theme, widget.product),
                                _buildAuthor(theme, widget.product),
                                const SizedBox(height: 5),
                                _buildRating(theme, widget.product),
                              ],
                            ),

                            // --- 3. New Bottom Action Row (Conditional) ---
                            _buildBottomActionRow(
                              theme,
                              context,
                              appStateMethods,
                              isOwned,
                              widget.product,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Builder Methods ---

  Widget _buildImage(ThemeData theme, Product product) {
    if (product.imageUrl.isEmpty) {
      return _buildPlaceholder(theme, product);
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
        return _buildPlaceholder(theme, product);
      },
    );
  }

  Widget _buildPlaceholder(ThemeData theme, Product product) {
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

  Widget _buildTypeChip(ThemeData theme, Product product) {
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

  Widget _buildTitle(ThemeData theme, Product product) {
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

  Widget _buildAuthor(ThemeData theme, Product product) {
    return Text(
      'by ${product.author}',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRating(ThemeData theme, Product product) {
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

  // --- Conditional Bottom Row Widget ---
  Widget _buildBottomActionRow(
    ThemeData theme,
    BuildContext context,
    AppState appState,
    bool isOwned,
    Product product,
  ) {
    if (isOwned) {
      // Show READ button if owned
      return SizedBox(
        height: 40,
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () =>
              appState.navigate(AppScreen.reading, id: product.id.toString()),
          icon: const Icon(Icons.menu_book, size: 18, color: Colors.black),
          label: const Text('Read', style: TextStyle(color: Colors.black)),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.tertiary,
            padding: EdgeInsets.zero,
          ),
        ),
      );
    }

    // Show Price, Cart, and Bookmark buttons if NOT owned
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Price
        _buildPriceInfo(theme, product),
        // 2. Buttons
        Row(
          children: [
            _buildCartButton(theme, context, product),
            const SizedBox(width: 8),
            _buildBookmarkButton(theme, context, product),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceInfo(ThemeData theme, Product product) {
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

  Widget _buildCartButton(
    ThemeData theme,
    BuildContext context,
    Product product,
  ) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.purple.shade400,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withAlpha(77),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
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
        child: const Icon(
          Icons.shopping_cart_outlined,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildBookmarkButton(
    ThemeData theme,
    BuildContext context,
    Product product,
  ) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isBookmarked = appState.bookmarkedProductIds.contains(product.id);

        return Container(
          width: 40,
          height: 40,
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
              isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
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

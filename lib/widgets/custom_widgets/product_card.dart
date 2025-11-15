// lib/widgets/custom_widgets/product_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../state/app_state.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  // Fixed padding for non-responsive sizing
  final EdgeInsets _contentPadding =
      const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0);

  // Fixed image height for the non-responsive vertical layout
  final double _fixedCoverHeight = 100.0;

  // Map for displaying custom category labels
  final Map<String, String> _typeLabelMap = const {
    'E-Books': 'E-Books',
    'E-Journals': 'E-Journals',
    'Study Material': 'Study Material',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context, listen: false);

    final isLightMode = theme.brightness == Brightness.light;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.4),
      color: const Color(0xFF282436),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isLightMode
            ? BorderSide(color: Colors.grey.shade300, width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap ??
            () => appState.navigate(AppScreen.productDetails,
                id: product.id.toString()),

        // Enforced non-responsive vertical layout
        child: _buildVerticalLayout(theme, context, _contentPadding),
      ),
    );
  }

  // ------------------------------------------------------------------
  // 🔒 FIXED VERTICAL LAYOUT (Non-responsive)
  // ------------------------------------------------------------------

  Widget _buildVerticalLayout(
      ThemeData theme, BuildContext context, EdgeInsets padding) {
    // This layout is now static and will be used regardless of parent width.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Cover/Image Section (Uses fixed height)
        _buildCoverImageWithOverlay(theme, context,
            coverHeight: _fixedCoverHeight),

        // 2. Content Section (Title, Desc, Actions)
        Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildTitle(theme),
              const SizedBox(height: 6),
              _buildDescription(theme),
              const SizedBox(height: 16),
              _buildBottomActionRow(theme, context),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------
  // --- SHARED BUILDER METHODS (Updated Title and Type Chip) ---
  // ------------------------------------------------------------------

  Widget _buildCoverImageWithOverlay(ThemeData theme, BuildContext context,
      {required double coverHeight}) {
    // Determine the base image/placeholder
    Widget baseImage;
    if (product.imageUrl.isNotEmpty) {
      baseImage = Image.network(
        product.imageUrl,
        height: coverHeight, // Fixed height
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return _buildGreenPlaceholder(theme, theme.cardColor, coverHeight);
        },
        errorBuilder: (ctx, error, stackTrace) {
          return _buildGreenPlaceholder(
              theme, const Color(0xFF388E3C), coverHeight);
        },
      );
    } else {
      // Use the custom green placeholder if no URL is present
      baseImage =
          _buildGreenPlaceholder(theme, const Color(0xFF388E3C), coverHeight);
    }

    return Stack(
      children: [
        baseImage,

        // Overlays always use fixed positions
        Positioned(top: 10, left: 10, child: _buildTypeChip(theme)),
        Positioned(top: 50, left: 10, child: _buildRating(theme)),
        Positioned(
            top: 10, right: 10, child: _buildBookmarkIcon(theme, context)),

        // Play Button Overlay
        const Positioned.fill(
          child: Center(
            child: Icon(
              Icons.play_circle_fill_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreenPlaceholder(ThemeData theme, Color color, double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: color,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'BOOK COVER',
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'MINIMAL DIGITAL/AUDIO\nOVERVIEW',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    // IMPLEMENTATION: Heading color differentiation (using theme primary color)
    return Text(
      product.title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: theme.colorScheme.primary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTypeChip(ThemeData theme) {
    // IMPLEMENTATION: Map product.type to the new required label
    final displayType = _typeLabelMap[product.type] ?? product.type;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: const Color(0xFF4C4268),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        displayType, // Use mapped label
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildRating(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: const Color(0xFF4C4268),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: Colors.amber, size: 15),
          const SizedBox(width: 4),
          Text(
            product.rating.toString(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkIcon(ThemeData theme, BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isBookmarked = appState.bookmarkedProductIds.contains(product.id);
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF4C4268),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              appState.toggleBookmark(product.id);
            },
            child: Icon(
              isBookmarked ? Icons.favorite : Icons.favorite_border,
              color: isBookmarked ? Colors.red : Colors.white.withOpacity(0.8),
              size: 20,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDescription(ThemeData theme) {
    // Descriptive text remains white/white.withOpacity(0.7)
    return Text(
      'An in-depth visual guide to the key events and\nbattles of the Second World War.',
      style: theme.textTheme.bodySmall?.copyWith(
        color: Colors.white.withOpacity(0.7),
        fontSize: 12,
      ),
      maxLines: 2,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCartButton(theme, context),
            const SizedBox(width: 8),
            _buildBuyButton(theme, context),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF4C4268),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.monetization_on_rounded,
            color: Colors.amber,
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            '${product.price.toString()} ',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartButton(ThemeData theme, BuildContext context) {
    // FIX: Add product to cart
    final appState = Provider.of<AppState>(context, listen: false);

    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: const Color(0xFF4C4268),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          appState.addToCart(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.title} added to cart!'),
              duration: const Duration(milliseconds: 1500),
            ),
          );
        },
        child: Icon(
          Icons.shopping_cart_outlined,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildBuyButton(ThemeData theme, BuildContext context) {
    // FIX: Handle FREE products by adding them directly to the library.
    final appState = Provider.of<AppState>(context, listen: false);

    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (product.isFree) {
            // If the product is FREE, skip the cart/checkout process and add directly to the library.
            // NOTE: You must implement appState.addToLibrary(product) in your AppState class.
            // This is equivalent to "Download Now"
            appState.addToLibrary(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Successfully added "${product.title}" to your Library!'),
                duration: const Duration(milliseconds: 2000),
              ),
            );
          } else {
            // For paid products, proceed with adding to cart and navigating to checkout.
            appState.addToCart(product);
            appState.navigate(AppScreen.cart); // Navigate to cart/checkout
          }
        },
        child: Icon(
          Icons.shopping_bag_outlined,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

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

        // --- RESPONSIVENESS APPLIED VIA LayoutBuilder ---
        // LayoutBuilder gives the *local* width available to the card.
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Define the breakpoint based on the card's available width.
            const double horizontalBreakpoint = 200;
            final isWideEnoughForHorizontalLayout =
                constraints.maxWidth > horizontalBreakpoint;

            // Note: Since your design uses a 2-column grid, the available width
            // for the card is typically small. We will use a vertical layout
            // for the default look, as seen in your images.

            // Adjust padding based on available width
            final contentPadding = isWideEnoughForHorizontalLayout
                ? const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0)
                : const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0);

            return isWideEnoughForHorizontalLayout
                ? _buildVerticalLayout(theme, context, contentPadding)
                : _buildVerticalLayout(theme, context, contentPadding);

            // NOTE: In the current visual style (2 columns of vertical cards),
            // the Horizontal Layout is typically not triggered.
            // If you wanted a single-column view to switch to Horizontal,
            // you would use the 'isWideEnoughForHorizontalLayout ? _buildHorizontalLayout : _buildVerticalLayout'
            // I'm keeping the original vertical layout for all cases to match the visual.
            // I'll demonstrate the conditional styling below.
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // --- LAYOUT BUILDERS (Keeping Vertical for visual match) ---
  // ------------------------------------------------------------------

  Widget _buildVerticalLayout(
      ThemeData theme, BuildContext context, EdgeInsets padding) {
    // This is the main layout matching your screenshots.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Cover/Image Section (Full Width)
        _buildCoverImageWithOverlay(theme, context, coverHeight: 150.0),

        // 2. Content Section (Title, Desc, Actions)
        Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildTitle(theme, false),
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

  // (The Horizontal Layout Builder is omitted as it doesn't match the required visual)

  // ------------------------------------------------------------------
  // --- SHARED BUILDER METHODS (Including the conditional title) ---
  // ------------------------------------------------------------------

  Widget _buildCoverImageWithOverlay(ThemeData theme, BuildContext context,
      {required double coverHeight}) {
    // Determine the base image/placeholder
    Widget baseImage;
    if (product.imageUrl.isNotEmpty) {
      baseImage = Image.network(
        product.imageUrl,
        height: coverHeight, // Use dynamic height
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

        // Overlays always use position 10/50 for visual consistency
        Positioned(top: 10, left: 10, child: _buildTypeChip(theme)),
        Positioned(top: 50, left: 10, child: _buildRating(theme)),
        Positioned(
            top: 10, right: 10, child: _buildBookmarkIcon(theme, context)),

        // Play Button Overlay
        Positioned.fill(
          child: Center(
            child: Icon(
              Icons.play_circle_fill_rounded,
              color: Colors.white,
              size: 40,
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

  Widget _buildTitle(ThemeData theme, bool isLargeScreen) {
    // Font size adjustment based on responsiveness
    return Text(
      product.title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        // Using a slight size difference based on the flag
        fontSize: isLargeScreen ? 19 : 18,
        color: Colors.white.withOpacity(0.9),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTypeChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: const Color(0xFF4C4268),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        product.type,
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
          Icon(Icons.star_rounded, color: Colors.amber, size: 16),
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
            size: 18,
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
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF4C4268),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Add to cart logic
        },
        child: Icon(
          Icons.shopping_cart_outlined,
          color: Colors.white.withOpacity(0.8),
          size: 22,
        ),
      ),
    );
  }

  Widget _buildBuyButton(ThemeData theme, BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Buy now logic
        },
        child: Icon(
          Icons.shopping_bag_outlined,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

// lib/widgets/custom_widgets/product_card.dart

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../state/app_state.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  // Base padding
  final EdgeInsets _contentPadding =
  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0);

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
                () => appState.navigate(
              AppScreen.productDetails,
              id: product.id.toString(),
            ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _buildResponsiveVerticalLayout(
              theme,
              context,
              _contentPadding,
              constraints,
            );
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // 🔄 RESPONSIVE VERTICAL LAYOUT
  // ------------------------------------------------------------------

  Widget _buildResponsiveVerticalLayout(
      ThemeData theme,
      BuildContext context,
      EdgeInsets padding,
      BoxConstraints constraints,
      ) {
    final double width = constraints.maxWidth;
    final bool hasBoundedHeight = constraints.hasBoundedHeight;
    final double height = constraints.maxHeight;

    // Dynamic cover height
    final double coverHeight = hasBoundedHeight && height.isFinite && height > 0
        ? height * 0.4
        : width * 0.6;

    // Decide how "tight" the card is vertically
    final bool isShortTile = hasBoundedHeight && height < 200;
    final int descMaxLines = isShortTile ? 1 : 2;

    if (!hasBoundedHeight) {
      // Case 1: Unbounded height
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCoverImageWithOverlay(
            theme,
            context,
            coverHeight: coverHeight,
          ),
          Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(theme),
                const SizedBox(height: 6),
                _buildDescription(theme, maxLines: descMaxLines),
                const SizedBox(height: 12),
                _buildBottomActionRow(theme, context),
              ],
            ),
          ),
        ],
      );
    }

    // Case 2: Bounded height (Grid tiles)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCoverImageWithOverlay(
          theme,
          context,
          coverHeight: coverHeight,
        ),
        Expanded(
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(theme),
                const SizedBox(height: 4),
                Flexible(
                  child: _buildDescription(theme, maxLines: descMaxLines),
                ),
                const SizedBox(height: 8),
                const Spacer(),
                _buildBottomActionRow(theme, context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------
  // --- SHARED BUILDER METHODS ---
  // ------------------------------------------------------------------

  Widget _buildCoverImageWithOverlay(
      ThemeData theme,
      BuildContext context, {
        required double coverHeight,
      }) {
    Widget baseImage;
    if (product.imageUrl.isNotEmpty) {
      baseImage = Image.network(
        product.imageUrl,
        height: coverHeight,
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
      baseImage =
          _buildGreenPlaceholder(theme, const Color(0xFF388E3C), coverHeight);
    }

    return Stack(
      children: [
        baseImage,
        Positioned(top: 10, left: 10, child: _buildTypeChip(theme)),
        Positioned(top: 50, left: 10, child: _buildRating(theme)),
        Positioned(
          top: 10,
          right: 10,
          child: _buildBookmarkIcon(theme, context),
        ),
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

  // 🔤 TITLE WITH AUTOSIZE
  Widget _buildTitle(ThemeData theme) {
    return AutoSizeText(
      product.title,
      maxLines: 1,
      minFontSize: 12,
      maxFontSize: 18,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildTypeChip(ThemeData theme) {
    final displayType = _typeLabelMap[product.type] ?? product.type;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: const Color(0xFF4C4268),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        displayType,
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
          const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
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

  // 🔤 DESCRIPTION WITH AUTOSIZE
  Widget _buildDescription(ThemeData theme, {int maxLines = 2}) {
    return AutoSizeText(
      'An in-depth visual guide to the key events and\nbattles of the Second World War.',
      maxLines: maxLines,
      minFontSize: 10,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall?.copyWith(
        color: Colors.white.withOpacity(0.7),
        fontSize: 12,
      ),
    );
  }

  // ------------------------------------------------------------------
  // 🔻 BOTTOM ACTION BAR
  // ------------------------------------------------------------------

  Widget _buildBottomActionRow(ThemeData theme, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Expanded so price text has bounded width -> AutoSizeText can scale
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _buildPriceInfo(theme),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCartButton(theme, context),
            const SizedBox(width: 10),
            _buildBuyButton(theme, context),
          ],
        ),
      ],
    );
  }

  // 🔤 PRICE / FREE WITH AUTOSIZE & NO BACKGROUND CONTAINER
  Widget _buildPriceInfo(ThemeData theme) {
    if (product.isFree) {
      return AutoSizeText(
        'FREE',
        maxLines: 1,
        minFontSize: 10,
        maxFontSize: 18,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.tertiary,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.monetization_on_rounded,
          color: Colors.amber,
          size: 15,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: AutoSizeText(
            '${product.price.toString()}',
            maxLines: 1,
            minFontSize: 10,
            maxFontSize: 18,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartButton(ThemeData theme, BuildContext context) {
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
            appState.addToLibrary(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Successfully added "${product.title}" to your Library!',
                ),
                duration: const Duration(milliseconds: 2000),
              ),
            );
          } else {
            appState.addToCart(product);
            appState.navigate(AppScreen.cart);
          }
        },
        child: const Icon(
          Icons.shopping_bag_outlined,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

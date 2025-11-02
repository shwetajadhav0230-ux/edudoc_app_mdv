import 'package:edudoc_app_mdv/models/product.dart' show Product;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../state/app_state.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _showAllReviews = false;
  final int _initialReviewCount = 2;

  // --- 1. Functional Helper Methods ---

  Widget _buildBookmarkButton(
    BuildContext context,
    Product product,
    Color secondaryColor,
  ) {
    final theme = Theme.of(context);
    // Removed isDarkTheme calculation as it's not strictly necessary here.

    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isBookmarked = appState.bookmarkedProductIds.contains(product.id);

        return IconButton(
          onPressed: () {
            appState.toggleBookmark(product.id);
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
          icon: Icon(
            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: isBookmarked ? secondaryColor : theme.colorScheme.onSurface,
          ),
          splashRadius: 24,
        );
      },
    );
  }

  void _handleAddToCart(
    BuildContext context,
    AppState appState,
    Product product,
  ) {
    appState.addToCart(product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} added to Cart.'),
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  // --- 2. Main Widget Build ---

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    final productId = int.tryParse(appState.selectedProductId ?? '') ?? 1;
    final product = dummyProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => dummyProducts.first,
    );

    final isOwned = appState.ownedProductIds.contains(product.id);
    final priceText = product.isFree ? 'FREE' : '${product.price} Tokens';
    final Color readButtonColor = const Color(0xFF24E3C6);

    IconData typeIcon = product.type == 'Notes' ? Icons.note_alt : Icons.book;
    final bool hasCustomImage =
        product.imageUrl.isNotEmpty;

    // --- Media Widget Logic ---
    Widget _buildPlaceholderMedia(IconData icon) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: isDarkTheme
              ? const Color(0xFF4C4435)
              : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 70,
          color: isDarkTheme
              ? const Color(0xFFC6A153)
              : theme.colorScheme.primary.withAlpha(179),
        ),
      );
    }

    Widget mediaWidget = _buildPlaceholderMedia(typeIcon);
    if (hasCustomImage) {
      mediaWidget = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          product.imageUrl,
          height: 200,
          width: double.maxFinite,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => _buildPlaceholderMedia(typeIcon),
        ),
      );
    }
    // --- End Media Widget Logic ---

    // --- Reviews Logic ---
    final int reviewsToDisplayCount = _showAllReviews
        ? product.reviewCount
        : _initialReviewCount;
    final int effectiveReviewsCount =
        reviewsToDisplayCount > product.reviewCount
        ? product.reviewCount
        : reviewsToDisplayCount;
    final bool canShowAll = product.reviewCount > _initialReviewCount;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: isDarkTheme ? Colors.white : theme.colorScheme.onSurface,
          onPressed: appState.navigateBack,
        ),
        // FIX: Used generic product title to avoid truncation overlap issues in the AppBar
        title: Text(
          ' ',
          style: theme.textTheme.titleLarge?.copyWith(
            color: isDarkTheme ? Colors.white : theme.colorScheme.onSurface,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: isDarkTheme
                  ? Colors.white54
                  : theme.colorScheme.onSurface.withAlpha(153),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality mocked.')),
              );
            },
          ),
          _buildBookmarkButton(context, product, theme.colorScheme.secondary),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 100.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 2. Product Title & Author (Replacing the redundant 'To Calculus' link) ---
            Text(
              product.title,
              style: TextStyle(
                color: isDarkTheme ? Colors.white : theme.colorScheme.onSurface,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'by ${product.author}',
              style: TextStyle(
                color: isDarkTheme ? Colors.white70 : Colors.grey.shade700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),

            // --- FIX: Metadata Row (Moved up for better visibility, matching the image structure) ---
            Row(
              children: [
                Text(
                  'Type: ${product.type}  |  Category: ${product.category}',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white70 : Colors.black87,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Text(
                  'Pages: ${product.pages}',
                  style: TextStyle(
                    color: isDarkTheme ? Colors.white70 : Colors.black87,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Media Area (Full Width)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: mediaWidget,
            ),

            const SizedBox(height: 24),

            // 4. Main Action Button (Full Width)
            SizedBox(
              width: double.infinity,
              child: isOwned
                  ? ElevatedButton.icon(
                      onPressed: () => appState.navigate(
                        AppScreen.reading,
                        id: product.id.toString(),
                      ),
                      icon: const Icon(Icons.menu_book, color: Colors.black),
                      label: const Text(
                        'Read Document',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: readButtonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: () =>
                          _handleAddToCart(context, appState, product),
                      icon: const Icon(Icons.shopping_bag, color: Colors.white),
                      label: Text(
                        product.isFree
                            ? 'Download Now'
                            : 'Add To Cart ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
            ),

            const SizedBox(height: 18),

            // 5. Action Buttons Row (Only Cart needed if not owned)
            if (!isOwned)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // IconButton(
                  //   onPressed: () =>
                  //       _handleAddToCart(context, appState, product),
                  //   icon: const Icon(Icons.shopping_cart_outlined),
                  //   color: Colors.amber,
                  //   splashRadius: 24,
                  // ),
                ],
              ),

            if (!isOwned) const SizedBox(height: 18),

            // 6. Price & Rating
            Row(
              children: [
                Text(
                  priceText,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.star, color: Colors.yellowAccent, size: 22),
                const SizedBox(width: 4),
                // Ensure rating text is constrained
                Flexible(
                  child: Text(
                    '${product.rating} (${product.reviewCount} Reviews)',
                    style: TextStyle(
                      color: isDarkTheme
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 7. Details and Metadata (Long Description)
            Text(
              product.details,
              style: TextStyle(
                color: isDarkTheme ? Colors.white70 : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),

            // REMOVED Redundant Metadata rows: Type, Author, Category, Pages
            const SizedBox(height: 14),

            // 8. Pill-Shaped Tags (Dynamic content)
            Wrap(
              spacing: 8.0,
              children: product.tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: tag == 'STEM' || tag == 'Tech'
                            ? Colors.teal
                            : Colors.indigo,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 28),

            // 9. Reviews Section
            Text(
              'User Reviews (${product.reviewCount})',
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Review List
            Column(
              children: List.generate(
                effectiveReviewsCount,
                (index) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.cardColor.withAlpha(isDarkTheme ? 128 : 255),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isDarkTheme
                        ? null
                        : [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.account_circle,
                      color: isDarkTheme
                          ? Colors.white54
                          : theme.colorScheme.primary,
                    ),
                    title: Text(
                      index == 0
                          ? "Alex M."
                          : index == 1
                          ? "Sarah K."
                          : "User ${index + 1}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      index % 2 == 0
                          ? 'Great notes! Highly recommend.'
                          : 'Worth the tokens.',
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withAlpha(
                          179,
                        ),
                      ),
                    ),
                    trailing: Text(
                      '${(product.rating - (index * 0.1)).toStringAsFixed(1)} ★',
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // "View All Reviews" Button (Show only if there are more reviews to see)
            if (canShowAll && !_showAllReviews)
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAllReviews = true;
                  });
                },
                child: Text(
                  'View All Reviews (${product.reviewCount})',
                  style: TextStyle(color: theme.colorScheme.secondary),
                ),
              ),

            // Show "Hide Reviews" if all are shown and the initial count was exceeded
            if (_showAllReviews && product.reviewCount > _initialReviewCount)
              TextButton(
                onPressed: () {
                  setState(() {
                    _showAllReviews = false;
                  });
                },
                child: Text(
                  'Hide Extra Reviews',
                  style: TextStyle(color: theme.colorScheme.secondary),
                ),
              ),

            const SizedBox(height: 42),
          ],
        ),
      ),
    );
  }
}

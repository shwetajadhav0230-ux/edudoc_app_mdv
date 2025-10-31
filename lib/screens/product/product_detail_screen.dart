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
  // State to track whether all reviews should be shown
  bool _showAllReviews = false;

  // Initial number of reviews to display (default is 2, as seen in previous mock structure)
  final int _initialReviewCount = 2;

  // --- 1. Functional Helper Methods (Cart/Bookmark/Reviews) ---

  // Helper widget to provide a dynamic Bookmark icon with action/feedback
  Widget _buildBookmarkButton(
    BuildContext context,
    Product product,
    Color secondaryColor,
  ) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isBookmarked = appState.bookmarkedProductIds.contains(product.id);

        return IconButton(
          onPressed: () {
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
          icon: Icon(
            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: isBookmarked ? secondaryColor : Colors.grey,
          ),
          splashRadius: 24,
        );
      },
    );
  }

  // Helper function to handle cart action with feedback
  void _handleAddToCart(
    BuildContext context,
    AppState appState,
    Product product,
  ) {
    appState.addToCart(product);

    // Show Snackbar confirmation
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
    final productId =
        int.tryParse(appState.selectedProductId ?? '') ??
        1; // Default to product 1
    final product = dummyProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => dummyProducts.first,
    );

    final isOwned = appState.bookmarkedProductIds.contains(product.id);
    final priceText = product.isFree ? 'FREE' : '${product.price} Tokens';
    final Color backupColor = const Color(0xFF24E3C6); // Read button color

    // Get the appropriate icon based on the product type
    IconData typeIcon = product.type == 'Notes' ? Icons.note_alt : Icons.book;

    // Check if the product has a valid image URL in the mock data
    final bool hasCustomImage =
        product.imageUrl != null && product.imageUrl.isNotEmpty;

    // --- Media Widget Logic ---
    Widget _buildPlaceholderMedia(IconData icon) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          // Custom color from your original layout
          color: const Color(0xFF4C4435),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 70, color: const Color(0xFFC6A153)),
      );
    }

    Widget mediaWidget = _buildPlaceholderMedia(typeIcon);
    if (hasCustomImage) {
      mediaWidget = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          product.imageUrl,
          height: 180,
          width: double.infinity,
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Back Button
          TextButton.icon(
            onPressed: appState.navigateBack,
            icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 22),
            label: const Text('Back', style: TextStyle(color: Colors.white70)),
          ),
          const SizedBox(height: 16),

          // 2. Media Area (Full Width)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: mediaWidget,
          ),

          const SizedBox(height: 24),

          // 3. Main Action Button (Full Width)
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
                      backgroundColor: backupColor, // Greenish color
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
                          : 'Purchase for ${product.price} T.',
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

          // 4. Action Buttons Row (Bookmark/Cart/Share - Full Width)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Bookmark/Wishlist (Left)
              _buildBookmarkButton(
                context,
                product,
                theme.colorScheme.secondary,
              ),

              // 2. Cart Icon (Center)
              IconButton(
                onPressed: () => _handleAddToCart(context, appState, product),
                icon: const Icon(Icons.shopping_cart_outlined),
                color: Colors.amber,
                splashRadius: 24,
              ),

              // 3. Share Button (Right)
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white54),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share functionality mocked.'),
                    ),
                  );
                },
                splashRadius: 24,
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 5. Title & Price (Dynamic content)
          Text(
            product.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
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
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 6. Details and Metadata
          Text(
            product.details,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 16),

          Text(
            'Type: ${product.type}    Author: ${product.author}',
            style: const TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 2),
          Text(
            'Category: ${product.category}    Pages: ${product.pages}',
            style: const TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 14),

          // Pill-Shaped Tags (Dynamic content)
          Wrap(
            spacing: 8.0,
            children: product.tags
                .map(
                  (tag) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Container(
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
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 28),

          // 7. Reviews Section (Dynamic data)
          Text(
            'User Reviews (${product.reviewCount})',
            style: const TextStyle(
              color: Color(0xFFD49AF9),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // Review List
          Column(
            children: List.generate(
              effectiveReviewsCount, // Use the state-controlled count
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF181F2A),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    const BoxShadow(color: Colors.black26, blurRadius: 8),
                  ],
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.account_circle,
                    color: Colors.white54,
                  ),
                  title: Text(
                    index == 0
                        ? "Alex M."
                        : index == 1
                        ? "Sarah K."
                        : "User ${index + 1}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    index % 2 == 0
                        ? 'Great notes! Highly recommend.'
                        : 'Worth the tokens.',
                    style: const TextStyle(color: Colors.white70),
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
                // FIX: Toggle state to show all reviews
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
                // FIX: Toggle state back to show initial reviews
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
    );
  }
}

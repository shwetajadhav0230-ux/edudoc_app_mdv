// Auto-generated screen from main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../state/app_state.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

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
    final isBookmarked = isOwned;
    final priceText = product.isFree ? 'FREE' : '${product.price} Tokens';
    final Color backupColor = const Color(0xFF14B8A6);

    // Get the appropriate icon based on the product type
    IconData typeIcon;
    if (product.type == 'Notes') {
      typeIcon = Icons.note_alt;
    } else if (product.type == 'Books') {
      typeIcon = Icons.book;
    } else if (product.type == 'Journals') {
      typeIcon = Icons.edit_note;
    } else {
      typeIcon = Icons.article;
    }

    // Check if the product has a valid image URL in the mock data
    final bool hasCustomImage =
        product.imageUrl != null && product.imageUrl.isNotEmpty;

    // --- Media Widget Builder ---
    Widget mediaWidget = Container(
      height: 250,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(typeIcon, size: 100, color: theme.colorScheme.primary),
    );

    if (hasCustomImage) {
      mediaWidget = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          product.imageUrl, // Use the URL from mock data
          height: 250,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 250,
              color: theme.colorScheme.primary.withOpacity(0.1),
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // Fallback to the Icon placeholder if network fails
            return mediaWidget;
          },
        ),
      );
    }
    // --- End Media Widget Builder ---

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: appState.navigateBack,
            icon: const Icon(Icons.arrow_back),
            label: Text(
              'Back to Listings',
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Media & Actions
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    mediaWidget, // Use the dynamically built media widget
                    const SizedBox(height: 16),
                    // Action Button (Purchase/Read)
                    SizedBox(
                      width: double.infinity,
                      child: isOwned
                          ? ElevatedButton.icon(
                              onPressed: () => appState.navigate(
                                AppScreen.reading,
                                id: product.id.toString(),
                              ),
                              icon: const Icon(
                                Icons.book_online,
                                color: Colors.black,
                              ),
                              label: const Text(
                                'Read Document',
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: backupColor,
                              ),
                            )
                          // NEW LOGIC: Add to Cart and then navigate to Cart screen
                          : ElevatedButton.icon(
                              onPressed: () {
                                appState.addToCart(product);
                                appState.navigate(AppScreen.cart);
                              },
                              icon: const Icon(
                                Icons.shopping_bag,
                                color: Colors.white,
                              ),
                              label: Text(
                                product.isFree
                                    ? 'Download Now'
                                    : 'Purchase for ${product.price} T.',
                                style: const TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    // Small Icons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Center the remaining button
                      children: [
                        // RETAINED: Bookmark/Library Button
                        IconButton(
                          onPressed: () => appState.toggleBookmark(product.id),
                          icon: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isBookmarked
                                ? theme.colorScheme.secondary
                                : Colors.grey,
                          ),
                        ),

                        // REMOVED: The small redundant shopping cart icon button
                        // IconButton(
                        //   onPressed: () => appState.addToCart(product),
                        //   icon: Icon(Icons.shopping_cart, color: backupColor),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right Column: Details & Reviews
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          priceText,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: product.isFree
                                ? backupColor
                                : theme.colorScheme.tertiary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.star, color: Colors.yellow),

                        // Use Expanded for constraint handling
                        Expanded(
                          child: Text(
                            '${product.rating} (${product.reviewCount} Reviews)',
                            style: TextStyle(color: Colors.grey.shade400),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product.details,
                      style: TextStyle(color: Colors.grey.shade300),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Author: ${product.author}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Category: ${product.category}'),
                    const SizedBox(height: 24),
                    Text(
                      'Reviews',
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    // Simplified Review List
                    Column(
                      children: List.generate(
                        2,
                        (index) => Card(
                          child: ListTile(
                            title: Text(
                              'User ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Great document!',
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                            trailing: const Text(
                              '5.0 ★',
                              style: TextStyle(color: Colors.yellow),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

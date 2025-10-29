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
    final isBookmarked =
        isOwned; // For the prototype, owned means bookmarked/in library
    final priceText = product.isFree ? 'FREE' : '${product.price} Tokens';
    // Define backupColor locally
    final Color backupColor = const Color(0xFF14B8A6);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: appState.navigateBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back '),
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
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.book,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Action Button
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
                          : ElevatedButton.icon(
                              onPressed: () => appState.addToCart(product),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
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
                        IconButton(
                          onPressed: () => appState.addToCart(product),
                          icon: Icon(Icons.shopping_cart, color: backupColor),
                        ),
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
                        Text(
                          '${product.rating} (${product.reviewCount} Reviews)',
                          style: TextStyle(color: Colors.grey.shade400),
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

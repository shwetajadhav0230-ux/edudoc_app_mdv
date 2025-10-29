// Auto-generated screen from main.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';
import '../../widgets/custom_widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    // Define backupColor locally

    final filteredProducts = dummyProducts.where((p) {
      if (appState.homeFilter == 'all') return true;
      if (appState.homeFilter == 'Free') return p.isFree;
      return p.type == appState.homeFilter;
    }).toList();

    final startIndex = (appState.homeCurrentPage - 1) * appState.itemsPerPage;
    final endIndex = min(
      startIndex + appState.itemsPerPage,
      filteredProducts.length,
    );
    final productsToDisplay =
        (filteredProducts.isNotEmpty && startIndex < endIndex)
        ? filteredProducts.sublist(startIndex, endIndex)
        : <Product>[];

    final totalPages = (filteredProducts.length / appState.itemsPerPage).ceil();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discover Premium Docs',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 24,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          // --- Role Switch Card ---

          // --- Offers Carousel (Simplified) ---
          GestureDetector(
            onTap: () => appState.navigate(AppScreen.offers),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                '50% OFF Back-to-School Bundle!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // --- My Library Shelf (Horizontal Scroll) ---
          Text(
            'My Library',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: appState.bookmarkedProductIds.isEmpty
                ? const Center(
                    child: Text(
                      'Your library is empty. Bookmark or purchase a document!',
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: min(appState.bookmarkedProductIds.length, 6),
                    itemBuilder: (context, index) {
                      final product = dummyProducts.firstWhere(
                        (p) => p.id == appState.bookmarkedProductIds[index],
                      );
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        child: ProductCard(product: product),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          // --- Filters ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['all', 'Notes', 'Books', 'Journals', 'Free']
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(
                          filter,
                          style: TextStyle(
                            color: appState.homeFilter == filter
                                ? Colors.white
                                : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        // Used MaterialStateProperty to set color on chips
                        color: WidgetStateProperty.resolveWith<Color>((
                          Set<WidgetState> states,
                        ) {
                          if (appState.homeFilter == filter) {
                            return theme.colorScheme.primary;
                          }
                          return theme.cardColor;
                        }),
                        onPressed: () => appState.applyHomeFilter(filter),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          // --- Product Listings ---
          Text(
            'Popular Listings',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.7,
            ),
            itemCount: productsToDisplay.length,
            itemBuilder: (context, index) {
              return ProductCard(product: productsToDisplay[index]);
            },
          ),
          const SizedBox(height: 32),
          // --- Pagination ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (index) {
              final page = index + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ElevatedButton(
                  onPressed: () => appState.goToPage(page),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appState.homeCurrentPage == page
                        ? theme.colorScheme.primary
                        : theme.cardColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(0),
                    minimumSize: const Size(40, 40),
                  ),
                  child: Text(
                    '$page',
                    style: TextStyle(
                      color: appState.homeCurrentPage == page
                          ? Colors.white
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

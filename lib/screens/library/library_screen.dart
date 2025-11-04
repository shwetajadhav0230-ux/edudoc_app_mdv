// lib/screens/library/library_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../state/app_state.dart';
import '../../models/product.dart'; // <-- Import Product model

// --- Import the correct card widget ---
import '../../widgets/custom_widgets/library_shelf_card.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // --- Data Filtering Logic using correct AppState lists ---

    // 1. Get Owned Products
    final List<Product> ownedProducts = dummyProducts
        .where((p) => appState.ownedProductIds.contains(p.id))
        .toList();

    // 2. Get Wishlisted (Bookmarked) Products
    final List<Product> wishlistedProducts = dummyProducts
        .where((p) => appState.bookmarkedProductIds.contains(p.id))
        .toList();
    // --- End Data Filtering Logic ---


    // Use DefaultTabController for the tab structure
    return DefaultTabController(
      length: 2, // We will have two tabs: Library and Wishlist
      child: Scaffold(
        // Use Scaffold to allow for the AppBar
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => appState.navigateBack(),
          ),
          title: Text('My Digital Library', style: theme.textTheme.titleLarge),
          elevation: 0,
          bottom: TabBar(
            indicatorColor: theme.colorScheme.primary, // Highlight color
            labelStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(text: 'MY LIBRARY (${ownedProducts.length})'),
              Tab(text: 'WISHLIST (${wishlistedProducts.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // --- 1. Owned Products Tab ---
            _buildProductGrid(
              context,
              products: ownedProducts,
              emptyMessage: 'Your library is empty. Purchase a document to see it here.',
            ),

            // --- 2. Wishlisted Products Tab ---
            _buildProductGrid(
              context,
              products: wishlistedProducts,
              emptyMessage: 'Your wishlist is empty. Bookmark a document to see it here.',
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build the grid for either tab
  Widget _buildProductGrid(
      BuildContext context, {
        required List<Product> products,
        required String emptyMessage,
      }) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        // This aspect ratio works well for the LibraryShelfCard
        // (width: ~100 / height: ~133 = 0.75)
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        // --- Use the LibraryShelfCard ---
        return LibraryShelfCard(
          product: product,
        );
      },
    );
  }
}
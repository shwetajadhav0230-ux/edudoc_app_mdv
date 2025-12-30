// lib/screens/library/library_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../models/product.dart';
import '../../widgets/custom_widgets/library_shelf_card.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    final List<Product> ownedProducts = appState.products
        .where((p) => appState.ownedProductIds.contains(p.id))
        .toList();

    final List<Product> wishlistedProducts = appState.products
        .where((p) => appState.bookmarkedProductIds.contains(p.id))
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => appState.navigateBack(),
          ),
          title: Text('My Digital Library', style: theme.textTheme.titleLarge),
          elevation: 0,
          bottom: TabBar(
            indicatorColor: theme.colorScheme.primary,
            labelStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'MY LIBRARY (${ownedProducts.length})'),
              Tab(text: 'WISHLIST (${wishlistedProducts.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildProductGrid(
              context,
              products: ownedProducts,
              emptyMessage: 'Your library is empty.',
              subMessage: 'Purchase a document to see it here.',
              icon: Icons.library_books_outlined,
              showBrowseButton: true,
            ),
            _buildProductGrid(
              context,
              products: wishlistedProducts,
              emptyMessage: 'Your wishlist is empty.',
              subMessage: 'Bookmark a document to see it here.',
              icon: Icons.favorite_outline,
              showBrowseButton: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(
      BuildContext context, {
        required List<Product> products,
        required String emptyMessage,
        required String subMessage,
        required IconData icon,
        required bool showBrowseButton,
      }) {
    final appState = Provider.of<AppState>(context, listen: false);
    final theme = Theme.of(context);

    if (products.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => appState.refreshData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 80, color: theme.colorScheme.onSurface.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text(emptyMessage, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(subMessage, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                if (showBrowseButton) ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => appState.navigate(AppScreen.home),
                    child: const Text('Browse Products'),
                  ),
                ]
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => appState.refreshData(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.75
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onLongPress: () async {
              if (emptyMessage.contains('wishlist')) {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Remove from Wishlist?'),
                    content: Text('Do you want to remove "${product.title}"?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Remove', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) appState.toggleBookmark(product.id);
              }
            },
            child: LibraryShelfCard(product: product),
          );
        },
      ),
    );
  }
}
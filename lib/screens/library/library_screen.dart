import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../data/mock_data.dart'; // REMOVED
import '../../state/app_state.dart';
import '../../models/product.dart';
import '../../widgets/custom_widgets/library_shelf_card.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // USE appState.products instead of dummyProducts
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
            _buildProductGrid(context, products: ownedProducts, emptyMessage: 'Your library is empty. Purchase a document to see it here.'),
            _buildProductGrid(context, products: wishlistedProducts, emptyMessage: 'Your wishlist is empty. Bookmark a document to see it here.'),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, {required List<Product> products, required String emptyMessage}) {
    if (products.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(32.0), child: Text(emptyMessage, textAlign: TextAlign.center)));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 16.0, mainAxisSpacing: 16.0, childAspectRatio: 0.75),
      itemCount: products.length,
      itemBuilder: (context, index) => LibraryShelfCard(product: products[index]),
    );
  }
}
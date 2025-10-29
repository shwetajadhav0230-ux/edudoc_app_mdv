// lib/screens/library/library_screen.dart

import 'package:edudoc_app_mdv/models/product.dart' show Product;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../state/app_state.dart';
import '../../widgets/custom_widgets/library_grid_item.dart'; // Import the new grid item

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Using DefaultTabController for the tab structure
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading:
              false, // Hide default back button in scaffold
          title: Text('My Digital Library', style: theme.textTheme.titleLarge),
          bottom: TabBar(
            indicatorColor: theme.colorScheme.primary, // Highlight color
            labelStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            tabs: const [
              Tab(text: 'CURRENT READS'),
              Tab(text: 'WISHLIST'), // Proxy for ARCHIVE / Reading Lists
              Tab(text: 'ALL DOCUMENTS'),
            ],
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.help_outline), // Question mark icon
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // 1. Current Reads Tab (Owned/Bookmarked Content)
            _buildProductGrid(context, filter: 'owned'),

            // 2. Wishlist Tab (Bookmarked Content - Filtered list, separate from owned)
            _buildProductGrid(context, filter: 'wishlist'),

            // 3. All Documents Tab (All content)
            _buildProductGrid(context, filter: 'all'),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, {required String filter}) {
    final appState = Provider.of<AppState>(context);

    // --- Data Filtering Logic ---
    final List<int> purchasedIds =
        appState.bookmarkedProductIds; // Use bookmarks as owned/purchased proxy
    final List<Product> displayedProducts = dummyProducts.where((p) {
      if (filter == 'all') return true;

      // NOTE: Since the prototype uses bookmarked IDs for owned content,
      // both 'owned' and 'wishlist' filters currently show the same list.
      if (filter == 'owned') {
        // Filter for documents the user has "acquired"
        return purchasedIds.contains(p.id);
      }
      if (filter == 'wishlist') {
        // Filter for non-owned documents that are bookmarked (or just all bookmarked items for now)
        return purchasedIds.contains(p.id);
      }
      return false;
    }).toList();
    // --- End Data Filtering Logic ---

    if (displayedProducts.isEmpty) {
      return Center(
        child: Text(
          'Your ${filter.toUpperCase()} is empty.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    // Display in a List/Grid view
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: displayedProducts.length,
      itemBuilder: (context, index) {
        return LibraryGridItem(product: displayedProducts[index]);
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../state/app_state.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // This filters ONLY for items whose IDs are in the bookmarked list,
    // fulfilling the 'wishlist' requirement.
    final wishlistedProducts = dummyProducts
        .where((p) => appState.bookmarkedProductIds.contains(p.id))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // FIX: Updated title to reflect "Wishlist"
            'My Wishlisted Documents',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 16),
          if (wishlistedProducts.isEmpty)
            const Center(
              child: Text('Your wishlist is empty. Add a document!'),
            ),
          ...wishlistedProducts.map(
            (p) => Card(
              child: ListTile(
                leading: Icon(
                  Icons.bookmark,
                  color: theme.colorScheme.secondary,
                ),
                title: Text(p.title),
                subtitle: Text(p.author),
                onTap: () => appState.navigate(
                  AppScreen.productDetails,
                  id: p.id.toString(),
                ),
                trailing: IconButton(
                  // Action is to remove from the wishlist/bookmarks
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => appState.toggleBookmark(p.id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

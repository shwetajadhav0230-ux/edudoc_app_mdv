import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../data/mock_data.dart'; // REMOVED
import '../../state/app_state.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // Use appState.products
    final wishlistedProducts = appState.products
        .where((p) => appState.bookmarkedProductIds.contains(p.id))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Wishlisted Documents', style: theme.textTheme.titleLarge?.copyWith(fontSize: 24)),
          const SizedBox(height: 16),
          if (wishlistedProducts.isEmpty)
            const Center(child: Text('Your wishlist is empty. Add a document!')),
          ...wishlistedProducts.map(
                (p) => Card(
              child: ListTile(
                leading: Icon(Icons.favorite, color: theme.colorScheme.secondary),
                title: Text(p.title),
                subtitle: Text(p.author),
                onTap: () => appState.navigate(AppScreen.productDetails, id: p.id.toString()),
                trailing: IconButton(
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
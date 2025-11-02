// Auto-generated screen from main.dart

// --- MODIFICATION: Removed ProductCard import ---
// import 'package:edudoc_app_mdv/widgets/custom_widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../state/app_state.dart';

// --- NEW: Import the new LibraryShelfCard ---
import '../../widgets/custom_widgets/library_shelf_card.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // FIX: Filter products based on the list of *owned* product IDs.
    final ownedProducts = dummyProducts
        .where((p) => appState.ownedProductIds.contains(p.id))
        .toList();

    return Scaffold(
      // Use Scaffold to allow for the AppBar (with back button)
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.navigateBack(),
        ),
        title: Text('My Digital Library', style: theme.textTheme.titleLarge),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            if (ownedProducts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50.0),
                  child: Text(
                    // Updated message to correctly reflect library purpose
                    'Your library is empty. Purchase a document to see it here.',
                  ),
                ),
              ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                // This aspect ratio works well for the new card
                // (width: 150 / height: 200 = 0.75)
                childAspectRatio: 0.75,
              ),
              itemCount: ownedProducts.length,
              itemBuilder: (context, index) {
                final product = ownedProducts[index];

                // --- MODIFICATION: Replaced ProductCard with LibraryShelfCard ---
                return LibraryShelfCard(
                  product: product,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
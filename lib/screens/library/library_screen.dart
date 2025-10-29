// Auto-generated screen from main.dart

import 'package:edudoc_app_mdv/widgets/custom_widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock_data.dart';
import '../../state/app_state.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);


    final ownedProducts = dummyProducts
        .where((p) => appState.bookmarkedProductIds.contains(p.id))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Digital Library',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 16),
          if (ownedProducts.isEmpty)
            const Center(
              child: Text(
                'Your library is empty. Purchase or bookmark a document.',
              ),
            ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.7,
            ),
            itemCount: ownedProducts.length,
            itemBuilder: (context, index) {
              final product = ownedProducts[index];
              return ProductCard(
                product: product,
                onTap: () => appState.navigate(AppScreen.productDetails, id: product.id.toString()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Auto-generated screen from main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../state/app_state.dart';
import '../../widgets/custom_widgets/summary_row.dart';

class OfferDetailsScreen extends StatelessWidget {
  const OfferDetailsScreen({super.key});

  // Helper function to handle the "Buy Bundle Now" button action
  void _handleBuyBundle(
      BuildContext context,
      AppState appState,
      dynamic offer,
      ) {
    appState.addBundleToCart(offer);

    // Navigate immediately to the Cart screen
    appState.navigate(AppScreen.cart);

    // Optional: Show Snackbar confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${offer.title} added to cart!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    // Fallback ID to ensure a product is found if selectedOfferId is null/invalid
    final offerId = int.tryParse(appState.selectedOfferId ?? '') ?? 201;

    final offer = dummyOffers.firstWhere(
          (o) => o.id == offerId,
      orElse: () => dummyOffers.first,
    );

    final Color backupColor = const Color(0xFF14B8A6);

    final bundledProducts = offer.productIds
        .map(
          (id) => dummyProducts.firstWhere(
            (p) => p.id == id,
        orElse: () => dummyProducts.first,
      ),
    )
        .toList();
    final originalPrice = bundledProducts.fold(0, (sum, p) => sum + p.price);
    final priceDisplay = offer.tokenPrice == 0
        ? 'FREE'
        : '${offer.tokenPrice} Tokens';

    // --- Logic for the Validity Flag ---
    final bool isActive = offer.status == 'Active';
    final Color flagColor = isActive ? Colors.green.shade600 : Colors.red.shade600;
    final String flagText = isActive ? 'Available' : offer.status; // e.g., 'Expired', 'Inactive'
    final IconData flagIcon = isActive ? Icons.check_circle : Icons.cancel;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.navigateBack(),
        ),
        title: Text(offer.title, style: theme.textTheme.titleLarge),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // --- MODIFICATION: Removed the Row(..) wrapper ---

            // --- MODIFICATION: Removed Expanded(...) wrapper ---
            // Summary & Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bundle Summary',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // --- Validity Flag Chip ---
                    Chip(
                      label: Text(
                        flagText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: flagColor,
                      avatar: Icon(
                        flagIcon,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),

                    const Divider(),
                    // Detailed Description/Details Section
                    Text(
                      'Description',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      // Placeholder text for offer details
                      'This is a limited-time bundle offering significant savings on our curated selection of top-rated documents. Ideal for jumpstarting a new semester or career focus.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pricing Section
                    Text('Pricing', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),

                    SummaryRow(
                      label: 'Total Value',
                      value: '$originalPrice T',
                    ),
                    SummaryRow(label: 'Discount', value: offer.discount),
                    SummaryRow(label: 'Duration', value: offer.duration),
                    const Divider(),
                    SummaryRow(
                      label: 'Bundle Price',
                      value: priceDisplay,
                      isTotal: true,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // This button is your "repurchase" button
                        onPressed: isActive
                            ? () => _handleBuyBundle(
                          context,
                          appState,
                          offer,
                        )
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: offer.tokenPrice == 0
                              ? backupColor
                              : theme.colorScheme.primary,
                        ), // Disables button if not active
                        child: Text(
                          offer.tokenPrice == 0
                              ? 'Claim Free Bundle'
                              : 'Buy Bundle Now',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- MODIFICATION: Added vertical spacing ---
            const SizedBox(height: 16),

            // --- MODIFICATION: Removed Expanded(...) wrapper ---
            // Products Included
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Included Documents (${bundledProducts.length})',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                      ),
                    ),
                    const Divider(),
                    // Document List
                    ...bundledProducts.map(
                          (p) => ListTile(
                        onTap: () => appState.navigate(
                          AppScreen.productDetails,
                          id: p.id.toString(),
                        ),
                        dense: true,
                        title: Text(
                          p.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Text(
                          '${p.price} T.',
                          style: TextStyle(
                            color: theme.colorScheme.tertiary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- MODIFICATION: Removed Row's closing tags ---
          ],
        ),
      ),
    );
  }
}
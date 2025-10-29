// Auto-generated screen from main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../state/app_state.dart';
import '../../widgets/custom_widgets/summary_row.dart';
// Note: AppScreen and Product models are assumed to be available via imports/scope
// from app_state.dart and mock_data.dart

class OfferDetailsScreen extends StatelessWidget {
  const OfferDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final offerId = int.tryParse(appState.selectedOfferId ?? '') ?? 201;
    final offer = dummyOffers.firstWhere(
      (o) => o.id == offerId,
      orElse: () => dummyOffers.first,
    );
    // Define backupColor locally for potential coloring (like the free badge)
    final Color backupColor = const Color(0xFF14B8A6);

    final bundledProducts = offer.productIds
        .map(
          (id) => dummyProducts.firstWhere(
            (p) => p.id == id,
            // Fallback for safety
            orElse: () => dummyProducts.first,
          ),
        )
        .toList();
    final originalPrice = bundledProducts.fold(0, (sum, p) => sum + p.price);
    final priceDisplay = offer.tokenPrice == 0
        ? 'FREE'
        : '${offer.tokenPrice} Tokens';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: appState.navigateBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Offers'),
          ),
          const SizedBox(height: 16),
          Text(
            offer.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 32,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary & Actions
              Expanded(
                child: Card(
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
                        const Divider(),
                        // ADDED: Detailed Description/Details Section
                        Text('Description', style: theme.textTheme.titleMedium),
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
                            onPressed: offer.status == 'Active'
                                ? () => appState.checkout()
                                : null,
                            child: Text(
                              offer.tokenPrice == 0
                                  ? 'Claim Free Bundle'
                                  : 'Buy Bundle Now',
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: offer.tokenPrice == 0
                                  ? backupColor
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        // Display status if inactive
                        if (offer.status != 'Active')
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Center(
                              child: Text(
                                'Offer is ${offer.status.toUpperCase()}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Products Included
              Expanded(
                child: Card(
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

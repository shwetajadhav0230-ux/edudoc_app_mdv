// Auto-generated screen from main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock_data.dart';
import '../../state/app_state.dart';
import '../../widgets/custom_widgets/summary_row.dart';
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

    final bundledProducts = offer.productIds
        .map((id) => dummyProducts.firstWhere((p) => p.id == id))
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
                          bold: true,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: offer.status == 'Active'
                                ? () => appState.checkout()
                                : null, // Mock checkout
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
                        ...bundledProducts.map(
                          (p) => ListTile(
                            dense: true,
                            title: Text(p.title),
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

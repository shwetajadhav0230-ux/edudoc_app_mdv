// Auto-generated screen from main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../state/app_state.dart';
// Assuming Offer and Product models/data are accessible
// NOTE: I am assuming the promotional banner is part of OffersScreen.

// --- Helper Widget: _OfferCard (Included for context but not modified) ---
class _OfferCard extends StatelessWidget {
  final offer; // Assuming dynamic type if Offer class not provided
  const _OfferCard({required this.offer});
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final theme = Theme.of(context);
    final priceDisplay = offer.tokenPrice == 0
        ? 'FREE'
        : '${offer.tokenPrice} T.';

    return Card(
      child: InkWell(
        onTap: () =>
            appState.navigate(AppScreen.offerDetails, id: offer.id.toString()),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    offer.duration,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(
                      offer.discount,
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    backgroundColor: theme.colorScheme.secondary,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 16),
                  Text(
                    priceDisplay,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// --- End Helper Widget ---

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  // Helper function to handle the promotional banner's button action
  void _handleBuyBanner(BuildContext context, AppState appState) {
    // 1. Add the mock Pro Pack to the cart
    appState.addProPackToCart();

    // 2. Navigate immediately to the Cart screen
    appState.navigate(AppScreen.cart);

    // Optional: Show Snackbar confirmation that the item was added
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Annual Pro Pack added to cart!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // Assuming dummyOffers is accessible
    final activeOffers = dummyOffers
        .where((o) => o.status == 'Active')
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Special Offers & Bundles',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 16),
          // Promotional Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.secondary,
                  theme.colorScheme.primary,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Unlock Unlimited Access!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get the Annual Pro Pack and save 300 tokens!',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  // FIX: Call the handler to add the Pro Pack and navigate to Cart
                  onPressed: () => _handleBuyBanner(context, appState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Buy Now',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Curated Subject Bundles',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          // Dynamic Offer Cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.2,
            ),
            itemCount: activeOffers.length,
            itemBuilder: (context, index) {
              final offer = activeOffers[index];
              return _OfferCard(
                offer: offer,
              ); // Use the locally defined helper widget
            },
          ),
        ],
      ),
    );
  }
}

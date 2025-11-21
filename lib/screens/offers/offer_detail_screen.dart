import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../data/mock_data.dart'; // REMOVED
import '../../state/app_state.dart';
import '../../widgets/custom_widgets/summary_row.dart';

class OfferDetailsScreen extends StatelessWidget {
  const OfferDetailsScreen({super.key});

  void _handleBuyBundle(BuildContext context, AppState appState, dynamic offer) {
    appState.addBundleToCart(offer);
    appState.navigate(AppScreen.cart);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${offer.title} added to cart!'), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final offerId = int.tryParse(appState.selectedOfferId ?? '') ?? 0;

    // Fetch from appState.offers
    if (appState.offers.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final offer = appState.offers.firstWhere(
          (o) => o.id == offerId,
      orElse: () => appState.offers.first,
    );

    final Color backupColor = const Color(0xFF14B8A6);

    // Fetch bundled products from appState.products
    final bundledProducts = offer.productIds.map((id) =>
        appState.products.firstWhere(
                (p) => p.id == id,
            orElse: () => appState.products.first // Fallback
        )
    ).toList();

    final originalPrice = bundledProducts.fold(0, (sum, p) => sum + p.price);
    final priceDisplay = offer.tokenPrice == 0 ? 'FREE' : '${offer.tokenPrice} Tokens';
    final bool isActive = offer.status == 'Active';
    final Color flagColor = isActive ? Colors.green.shade600 : Colors.red.shade600;
    final String flagText = isActive ? 'Available' : offer.status;
    final IconData flagIcon = isActive ? Icons.check_circle : Icons.cancel;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => appState.navigateBack()),
        title: Text(offer.title, style: theme.textTheme.titleLarge),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bundle Summary', style: theme.textTheme.titleLarge?.copyWith(fontSize: 20)),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(flagText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: flagColor,
                      avatar: Icon(flagIcon, color: Colors.white, size: 18),
                    ),
                    const Divider(),
                    Text('Description', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('This is a limited-time bundle offering significant savings.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                    const SizedBox(height: 16),
                    Text('Pricing', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    SummaryRow(label: 'Total Value', value: '$originalPrice T'),
                    SummaryRow(label: 'Discount', value: offer.discount),
                    SummaryRow(label: 'Duration', value: offer.duration),
                    const Divider(),
                    SummaryRow(label: 'Bundle Price', value: priceDisplay, isTotal: true),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isActive ? () => _handleBuyBundle(context, appState, offer) : null,
                        style: ElevatedButton.styleFrom(backgroundColor: offer.tokenPrice == 0 ? backupColor : theme.colorScheme.primary),
                        child: Text(offer.tokenPrice == 0 ? 'Claim Free Bundle' : 'Buy Bundle Now', style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Included Documents (${bundledProducts.length})', style: theme.textTheme.titleLarge?.copyWith(fontSize: 20)),
                    const Divider(),
                    ...bundledProducts.map(
                          (p) => ListTile(
                        onTap: () => appState.navigate(AppScreen.productDetails, id: p.id.toString()),
                        dense: true,
                        title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                        trailing: Text('${p.price} T.', style: TextStyle(color: theme.colorScheme.tertiary)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../data/mock_data.dart'; // REMOVED
import '../../state/app_state.dart';

class _OfferCard extends StatelessWidget {
  final dynamic offer;
  const _OfferCard({required this.offer});
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final theme = Theme.of(context);
    final priceDisplay = offer.tokenPrice == 0 ? 'FREE' : '${offer.tokenPrice} T.';

    return Card(
      child: InkWell(
        onTap: () => appState.navigate(AppScreen.offerDetails, id: offer.id.toString()),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(offer.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(offer.duration, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(offer.discount, style: const TextStyle(fontSize: 10, color: Colors.white)),
                    backgroundColor: theme.colorScheme.secondary,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 16),
                  Text(priceDisplay, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.tertiary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  void _handleBuyBanner(BuildContext context, AppState appState) {
    appState.addProPackToCart();
    appState.navigate(AppScreen.cart);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Annual Pro Pack added to cart!'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // Use appState.offers
    final activeOffers = appState.offers.where((o) => o.status == 'Active').toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => appState.navigateBack()),
        title: Text('Special Offers & Bundles', style: theme.textTheme.titleLarge),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(colors: [theme.colorScheme.secondary, theme.colorScheme.primary]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Unlock Unlimited Access!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text('Get the Annual Pro Pack and save 300 tokens!', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _handleBuyBanner(context, appState),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: const Text('Buy Now', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Curated Subject Bundles', style: theme.textTheme.titleLarge?.copyWith(fontSize: 20)),
            const SizedBox(height: 8),
            if (appState.isLoadingOffers && activeOffers.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (activeOffers.isEmpty)
              const Text("No active offers at the moment.")
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 16.0, mainAxisSpacing: 16.0, childAspectRatio: 1.1),
                itemCount: activeOffers.length,
                itemBuilder: (context, index) => _OfferCard(offer: activeOffers[index]),
              ),
          ],
        ),
      ),
    );
  }
}
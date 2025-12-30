// lib/screens/offers/offer_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../models/offer.dart';
import '../../models/product.dart'; // ✅ Added import for Product

class OfferDetailsScreen extends StatelessWidget {
  const OfferDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final offerId = int.tryParse(appState.selectedOfferId ?? '') ?? 0;

    // Find offer safely
    final Offer offer = appState.offers.firstWhere(
          (o) => o.id == offerId,
      // ✅ FIXED: Added 'duration' and matches new Offer fields
      orElse: () => Offer(
          id: 0,
          title: 'Offer Not Found',
          description: '',
          discount: '',
          duration: '',     // ✅ Added missing parameter
          tokenPrice: 0,
          productIds: [],
          status: 'Inactive',
          imageUrl: ''
      ),
    );

    if (offer.id == 0) {
      return Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: appState.navigateBack)),
        body: const Center(child: Text("Offer not found.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(offer.title),
        leading: BackButton(onPressed: appState.navigateBack),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offer Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage('assets/images/${offer.imageUrl}'),
                  fit: BoxFit.cover,
                  onError: (_, __) {},
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title & Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(offer.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '${offer.tokenPrice} Tokens',
                    style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(offer.description, style: const TextStyle(fontSize: 16, height: 1.5)),
            const SizedBox(height: 30),

            // Included Items
            const Text("Included Documents:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...offer.productIds.map((pid) {
              final product = appState.products.firstWhere(
                      (p) => p.id == pid,
                  orElse: () => Product(id: 0, title: 'Unknown Product', type: '', description: '', price: 0, isFree: false, category: '', tags: [], rating: 0, author: '', pages: 0, reviewCount: 0, details: '', content: '', imageUrl: '')
              );
              if (product.id == 0) return const SizedBox.shrink();

              return ListTile(
                leading: const Icon(Icons.description, color: Colors.blueAccent),
                title: Text(product.title),
                subtitle: Text(product.author),
                trailing: const Icon(Icons.check_circle, color: Colors.green, size: 16),
              );
            }),

            const SizedBox(height: 40),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Placeholder for future bundle logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bundle purchasing coming soon!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey, // Disabled look for now
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Purchase Bundle (Coming Soon)', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
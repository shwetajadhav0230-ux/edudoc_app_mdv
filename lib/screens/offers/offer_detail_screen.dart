// lib/screens/offers/offer_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../models/offer.dart';
import '../../models/product.dart';

class OfferDetailsScreen extends StatefulWidget {
  const OfferDetailsScreen({super.key});

  @override
  State<OfferDetailsScreen> createState() => _OfferDetailsScreenState();
}

class _OfferDetailsScreenState extends State<OfferDetailsScreen> {
  // ✅ Controller for the PIN input
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  // ✅ 1. ADD PIN DIALOG (Same as CartScreen)
  void _showPINConfirmationDialog(BuildContext context, Offer offer) {
    _pinController.clear();
    final appState = Provider.of<AppState>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String? localErrorText;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setLocalState) {
            return AlertDialog(
              title: const Text('Confirm Bundle Purchase'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Enter your 4-digit Transaction PIN to confirm purchasing "${offer.title}" for ${offer.tokenPrice} tokens.',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: InputDecoration(
                      labelText: 'Transaction PIN',
                      errorText: localErrorText,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.dialpad),
                    ),
                    onChanged: (_) {
                      if (localErrorText != null) {
                        setLocalState(() => localErrorText = null);
                      }
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(), // Cancel
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final enteredPin = _pinController.text;

                    // ✅ Verify PIN with AppState
                    bool isValid = await appState.verifyTransactionPin(enteredPin);

                    if (isValid) {
                      Navigator.of(context).pop(); // Close Dialog

                      // ✅ Proceed with Purchase
                      if (mounted) {
                        appState.purchaseBundle(offer, context);
                      }
                    } else {
                      // Show Error in Dialog
                      setLocalState(() => localErrorText = 'Incorrect PIN.');
                    }
                  },
                  child: const Text('Confirm & Buy'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final offerId = int.tryParse(appState.selectedOfferId ?? '') ?? 0;

    final Offer offer = appState.offers.firstWhere(
          (o) => o.id == offerId,
      orElse: () => Offer(
        id: 0,
        title: 'Offer Not Found',
        coverImageUrl: null,
        discountLabel: '',
        discount: '',
        duration: '',
        tokenPrice: 0,
        productIds: [],
        status: 'Inactive',
      ),
    );

    if (offer.id == 0) {
      return Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: appState.navigateBack)),
        body: const Center(child: Text("Offer not found.")),
      );
    }

    final imageProvider = (offer.coverImageUrl != null && offer.coverImageUrl!.isNotEmpty)
        ? NetworkImage(offer.coverImageUrl!) as ImageProvider
        : const AssetImage('assets/images/placeholder_offer.png');

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
            // Banner Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: imageProvider,
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
                  child: Text(offer.title,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '${offer.tokenPrice} Tokens',
                    style: TextStyle(
                        color: Colors.green.shade800, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(offer.discountLabel ?? 'Exclusive Bundle Deal',
                style: const TextStyle(fontSize: 16, height: 1.5)),
            const SizedBox(height: 30),

            // Included Docs
            const Text("Included Documents:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...offer.productIds.map((pid) {
              final product = appState.products.firstWhere((p) => p.id == pid,
                  orElse: () => Product(id: 0, title: 'Unknown Product', type: '', description: '', price: 0, isFree: false, category: '', tags: [], rating: 0, author: '', pages: 0, reviewCount: 0, details: '', content: '', imageUrl: ''));

              if (product.id == 0) return const SizedBox.shrink();

              final Widget leadingWidget = (product.imageUrl.isNotEmpty)
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(product.imageUrl,
                    width: 50, height: 50, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.description, size: 40, color: Colors.blueAccent)),
              )
                  : const Icon(Icons.description, size: 40, color: Colors.blueAccent);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                leading: leadingWidget,
                title: Text(product.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(product.author),
                trailing: const Icon(Icons.check_circle, color: Colors.green, size: 20),
              );
            }),
            const SizedBox(height: 40),

            // ✅ 2. UPDATED ACTION BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Check if PIN is set first
                  if (!appState.isTransactionPinSet) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please set a Transaction PIN in Settings first.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  } else {
                    // Show the PIN dialog instead of immediate purchase
                    _showPINConfirmationDialog(context, offer);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Purchase Bundle (${offer.tokenPrice} Tokens)',
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// lib/screens/offers/offers_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../models/offer.dart';
import '../../utils/responsive_values.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Offers'),
        elevation: 0,
      ),
      body: appState.isLoadingOffers
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () => appState.refreshData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Limited Time Deals',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Grab these exclusive bundles before they expire!',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              if (appState.offers.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50.0),
                    child: Text("No active offers at the moment."),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appState.offers.length,
                  separatorBuilder: (context, index) =>
                  const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final offer = appState.offers[index];
                    return _buildOfferCard(context, offer, appState);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, Offer offer, AppState appState) {
    final theme = Theme.of(context);

    // ✅ Handle nullable cover image
    final imageProvider = (offer.coverImageUrl != null && offer.coverImageUrl!.isNotEmpty)
        ? NetworkImage(offer.coverImageUrl!) as ImageProvider
        : const AssetImage('assets/images/placeholder_offer.png'); // Ensure you have a placeholder or remove this

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => appState.navigate(AppScreen.offerDetails, id: offer.id.toString()),
        child: Column(
          children: [
            // Image Banner
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  onError: (_, __) {},
                ),
              ),
              alignment: Alignment.topRight,
              child: offer.discount != null // ✅ Check for null
                  ? Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  offer.discount!, // ✅ Force unwrap after check
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )
                  : null,
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(offer.title,
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 18)),
                  const SizedBox(height: 4),
                  // ✅ Use discountLabel as description fallback since 'description' column doesn't exist
                  Text(offer.discountLabel ?? 'Special Bundle',
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${offer.tokenPrice} Tokens',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
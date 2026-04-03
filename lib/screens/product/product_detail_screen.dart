// lib/screens/product/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../models/product.dart';
import '../../models/review.dart';
import 'reading_screen.dart';
import '../../widgets/custom_widgets/audio_player_sheet.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailsScreen> {
  final TextEditingController _reviewController = TextEditingController();
  double _userRating = 5.0;
  bool _isSubmittingReview = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final productId = int.tryParse(appState.selectedProductId ?? '') ?? 0;

    // Find product safely
    final product = appState.products.firstWhere(
      (p) => p.id == productId,
      orElse: () => Product(
        id: 0,
        title: 'Product Not Found',
        type: '',
        description: '',
        price: 0,
        isFree: false,
        category: '',
        tags: [],
        rating: 0,
        author: '',
        pages: 0,
        reviewCount: 0,
        details: '',
        content: '',
        imageUrl: '',
      ),
    );

    if (product.id == 0) {
      return Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: appState.navigateBack)),
        body: const Center(child: Text("Product not found")),
      );
    }

    final isOwned = appState.ownedProductIds.contains(product.id);
    final isInCart = appState.cartItems.any((item) => item.id == product.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title, style: const TextStyle(fontSize: 16)),
        leading: BackButton(onPressed: appState.navigateBack),
        actions: [
          IconButton(
            icon: Icon(
              appState.bookmarkedProductIds.contains(product.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: appState.bookmarkedProductIds.contains(product.id)
                  ? Colors.red
                  : null,
            ),
            onPressed: () => appState.toggleBookmark(product.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cover Image with optional audio overlay
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.imageUrl,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 300,
                        width: double.infinity,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.book,
                            size: 80, color: Colors.grey),
                      ),
                    ),
                  ),
                  // Play button — always visible; grey when no audio set
                  GestureDetector(
                    onTap: () async {
                      if (product.audioUrl == null ||
                          product.audioUrl!.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('No audio available for this product.')),
                        );
                        return;
                      }

                      // Check if there is a downloaded offline audio file
                      final appState =
                          Provider.of<AppState>(context, listen: false);
                      String? localPath;
                      if (appState.offlineProducts
                          .any((p) => p.id == product.id)) {
                        localPath = await appState
                            .getOfflineAudioPath(product.id.toString());
                      }

                      if (context.mounted) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => AudioPlayerSheet(
                            title: product.title,
                            author: product.author,
                            coverImageUrl: product.imageUrl,
                            audioUrl: product.audioUrl,
                            localAudioPath: localPath,
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: (product.audioUrl != null &&
                                product.audioUrl!.isNotEmpty)
                            ? Colors.black.withOpacity(0.55)
                            : Colors.black.withOpacity(0.30),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        (product.audioUrl != null &&
                                product.audioUrl!.isNotEmpty)
                            ? Icons.play_arrow
                            : Icons.music_off,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Title, Author, Rating
            Text(
              product.title,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "by ${product.author}",
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                const SizedBox(width: 4),
                Text(
                  "${product.rating} (${product.reviewCount} reviews)",
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const Spacer(),
                if (!isOwned && !product.isFree)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${product.price} Tokens",
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. ACTION BUTTONS (Read/Download vs Buy)
            if (isOwned) ...[
              // ✅ OWNED: Show Read + Download
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.menu_book),
                      label: const Text("READ NOW",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        // Open Reader Screen
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ReadingScreen()));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.download_rounded),
                      label: const Text("OFFLINE"),
                      onPressed: () {
                        // Download for offline use
                        appState.downloadForOffline(product);
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              // ✅ UNOWNED: Add to Cart / Library
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (product.isFree) {
                          appState.addToLibrary(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Added to Library!")),
                          );
                        } else {
                          if (isInCart) {
                            appState.navigate(AppScreen.cart);
                          } else {
                            appState.addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Added to Cart")),
                            );
                          }
                        }
                      },
                      child: Text(
                        product.isFree
                            ? "ADD TO LIBRARY (FREE)"
                            : (isInCart ? "GO TO CART" : "ADD TO CART"),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // 4. Description
            const Text("Description",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              product.description,
              style: const TextStyle(
                  fontSize: 15, height: 1.5, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // 5. Details Section
            const Text("Details",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            _buildDetailRow("Type", product.type),
            _buildDetailRow("Category", product.category),
            _buildDetailRow("Pages", "${product.pages}"),

            const Divider(height: 40),

            // 6. Reviews Section
            Text("Reviews (${product.reviewCount})",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 16),

            // Add Review Input
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Write a Review",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _userRating = index + 1.0),
                          child: Icon(
                            index < _userRating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _reviewController,
                      decoration: const InputDecoration(
                        hintText: "Share your thoughts...",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmittingReview
                            ? null
                            : () async {
                                if (_reviewController.text.trim().isEmpty)
                                  return;
                                setState(() => _isSubmittingReview = true);
                                await appState.submitReview(product.id,
                                    _userRating, _reviewController.text);
                                _reviewController.clear();
                                setState(() => _isSubmittingReview = false);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Review submitted!")));
                                }
                              },
                        child: _isSubmittingReview
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Text("Post Review"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Reviews List
            FutureBuilder<List<Review>>(
              future: appState.fetchProductReviews(product
                  .id), // Ensure this method exists or use DataService directly
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No reviews yet. Be the first!",
                      style: TextStyle(color: Colors.grey));
                }
                final reviews = snapshot.data!;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    // ✅ FIXED: Safely handle nullable userName
                    final displayName =
                        (review.userName != null && review.userName!.isNotEmpty)
                            ? review.userName!
                            : 'Anonymous';

                    final initial =
                        displayName.isNotEmpty ? displayName[0] : 'U';

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.2),
                        child: Text(initial),
                      ),
                      title: Text(displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(
                                5,
                                (i) => Icon(
                                      i < review.rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 14,
                                      color: Colors.amber,
                                    )),
                          ),
                          const SizedBox(height: 4),
                          Text(review.comment),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 100,
              child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

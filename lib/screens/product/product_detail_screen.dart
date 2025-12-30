import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/product.dart';
import '../../models/review.dart';
import '../../state/app_state.dart';
import '../../services/data_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _showAllReviews = false;
  final int _initialReviewCount = 2;
  List<Review> _realReviews = [];
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchReviews();
    });
  }

  Future<void> _fetchReviews() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final productId = int.tryParse(appState.selectedProductId ?? '') ?? 0;

    if (productId != 0) {
      final reviews = await DataService().getProductReviews(productId);
      if (mounted) {
        setState(() {
          _realReviews = reviews;
          _isLoadingReviews = false;
        });
      }
    }
  }

  void _handleAddToCart(BuildContext context, AppState appState, Product product) {
    appState.addToCart(product);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${product.title} added to Cart.'),
      duration: const Duration(milliseconds: 1000),
    ));
  }

  void _showReviewModal(BuildContext context, AppState appState, int productId, {double initialRating = 5.0}) {
    double selectedRating = initialRating;
    final TextEditingController commentController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Write a Review', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('How would you rate this document?'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => IconButton(
                  icon: Icon(
                    index < selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                  onPressed: () => setModalState(() => selectedRating = index + 1.0),
                )),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Share your experience...',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : () async {
                    // 1. Validation
                    if (commentController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a comment')));
                      return;
                    }

                    setModalState(() => isSubmitting = true);

                    try {
                      // 2. UPDATED: Call appState.submitReview
                      // We pass productId, selectedRating, and the comment.
                      // The appState logic already knows the user's ID and Name.
                      await appState.submitReview(
                          productId,
                          selectedRating,
                          commentController.text.trim()
                      );

                      if (context.mounted) {
                        Navigator.pop(context); // Close the modal
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Review posted! Thank you.')));

                        // 3. Refresh the local review list on this screen
                        _fetchReviews();
                      }
                    } catch (e) {
                      setModalState(() => isSubmitting = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to post review: $e')));
                      }
                    }
                  },
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Post Review'),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final productId = int.tryParse(appState.selectedProductId ?? '') ?? 1;

    final product = appState.products.firstWhere(
          (p) => p.id == productId,
      orElse: () => appState.products.first,
    );

    final isOwned = appState.ownedProductIds.contains(product.id);
    final totalRealCount = _realReviews.length;
    final int displayCount = _showAllReviews ? totalRealCount : (_initialReviewCount > totalRealCount ? totalRealCount : _initialReviewCount);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: appState.navigateBack
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () => Share.share('Check out "${product.title}" on EduDoc!')
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text('by ${product.author}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),

            // Interactive Star Rating Summary Block
            Row(
              children: [
                Row(
                  children: List.generate(5, (index) => GestureDetector(
                    onTap: () => _showReviewModal(context, appState, product.id, initialRating: index + 1.0),
                    child: Icon(
                      index < product.rating.floor() ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 24,
                    ),
                  )),
                ),
                const SizedBox(width: 8),
                Text(product.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(' ($totalRealCount reviews)', style: const TextStyle(color: Colors.grey)),
              ],
            ),

            const SizedBox(height: 20),
            if (product.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(product.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
              ),

            const SizedBox(height: 24),
            Text('Description', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(product.description, style: const TextStyle(height: 1.5)),

            const SizedBox(height: 32),
            // Primary Actions (Read or Buy)
            isOwned
                ? Row(
              children: [
                // READ NOW BUTTON
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => appState.navigate(AppScreen.reading, id: product.id.toString()),
                    icon: const Icon(Icons.menu_book),
                    label: const Text('Read Now'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // OFFLINE DOWNLOAD BUTTON
                // Checks if this specific product is currently downloading
                if (appState.downloadProgress.containsKey(product.id.toString()))
                  const SizedBox(
                      width: 48,
                      height: 48,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                  )
                else
                  OutlinedButton(
                    onPressed: () {
                      appState.downloadDocument(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Download started...')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      side: BorderSide(color: theme.colorScheme.primary),
                    ),
                    child: const Icon(Icons.download_for_offline),
                  ),
              ],
            )
                : Row(children: [
              Expanded(child: ElevatedButton(
                onPressed: () => _handleAddToCart(context, appState, product),
                child: Text(product.isFree ? 'Download' : 'Add to Cart'),
              ))
            ]),

            const Divider(height: 60),

            // Detailed Reviews List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('User Reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                if (isOwned) TextButton(
                  onPressed: () => _showReviewModal(context, appState, product.id),
                  child: const Text('Write a Review'),
                ),
              ],
            ),

            if (_isLoadingReviews)
              const Center(child: CircularProgressIndicator())
            else if (_realReviews.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No reviews yet. Be the first!')),
              )
            else
              Column(
                children: [
                  ...List.generate(displayCount, (index) {
                    final review = _realReviews[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(review.userName ?? 'Verified User'),
                      subtitle: Text(review.comment),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(' ${review.rating.round()}'),
                        ],
                      ),
                    );
                  }),
                  if (totalRealCount > _initialReviewCount)
                    TextButton(
                      onPressed: () => setState(() => _showAllReviews = !_showAllReviews),
                      child: Text(_showAllReviews ? 'Show Less' : 'View All $totalRealCount Reviews'),
                    ),
                ],
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
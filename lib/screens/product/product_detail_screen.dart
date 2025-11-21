import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../data/mock_data.dart'; // REMOVED
import '../../models/product.dart';
import '../../state/app_state.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _showAllReviews = false;
  final int _initialReviewCount = 2;

  void _handleAddToCart(BuildContext context, AppState appState, Product product) {
    appState.addToCart(product);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${product.title} added to Cart.'),
      duration: const Duration(milliseconds: 1000),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final productId = int.tryParse(appState.selectedProductId ?? '') ?? 1;

    // Logic to handle loading/empty state
    if (appState.products.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final product = appState.products.firstWhere(
          (p) => p.id == productId,
      orElse: () => appState.products.first,
    );

    final isOwned = appState.ownedProductIds.contains(product.id);
    final priceText = product.isFree ? 'FREE' : '${product.price} Tokens';
    final Color readButtonColor = const Color(0xFF24E3C6);
    IconData typeIcon = product.type == 'Notes' ? Icons.note_alt : Icons.book;
    final bool hasCustomImage = product.imageUrl.isNotEmpty;

    // ... [Keep helper widget buildPlaceholderMedia same as before] ...
    Widget buildPlaceholderMedia(IconData icon) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: isDarkTheme ? const Color(0xFF4C4435) : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 70, color: isDarkTheme ? const Color(0xFFC6A153) : theme.colorScheme.primary.withAlpha(179)),
      );
    }

    Widget mediaWidget = buildPlaceholderMedia(typeIcon);
    if (hasCustomImage) {
      mediaWidget = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(product.imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => buildPlaceholderMedia(typeIcon)),
      );
    }

    final int reviewsToDisplayCount = _showAllReviews ? product.reviewCount : _initialReviewCount;
    final int effectiveReviewsCount = reviewsToDisplayCount > product.reviewCount ? product.reviewCount : reviewsToDisplayCount;
    final bool canShowAll = product.reviewCount > _initialReviewCount;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), color: isDarkTheme ? Colors.white : theme.colorScheme.onSurface, onPressed: appState.navigateBack),
        title: Text(' ', style: theme.textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.share_outlined, color: isDarkTheme ? Colors.white54 : theme.colorScheme.onSurface.withAlpha(153)), onPressed: () {}),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 100.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.title, style: TextStyle(color: isDarkTheme ? Colors.white : theme.colorScheme.onSurface, fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('by ${product.author}', style: TextStyle(color: isDarkTheme ? Colors.white70 : Colors.grey.shade700, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Type: ${product.type}  |  Category: ${product.category}', style: TextStyle(color: isDarkTheme ? Colors.white70 : Colors.black87, fontSize: 15)),
                const Spacer(),
                Text('Pages: ${product.pages}', style: TextStyle(color: isDarkTheme ? Colors.white70 : Colors.black87, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(borderRadius: BorderRadius.circular(16), child: mediaWidget),
            const SizedBox(height: 24),
            isOwned
                ? SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => appState.navigate(AppScreen.reading, id: product.id.toString()),
                icon: const Icon(Icons.menu_book, color: Colors.black),
                label: const Text('Read Document', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: readButtonColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            )
                : Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleAddToCart(context, appState, product),
                    icon: Icon(product.isFree ? Icons.download : Icons.shopping_bag, color: Colors.white),
                    label: Text(product.isFree ? 'Download Now' : 'Add To Cart', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Consumer<AppState>(
                  builder: (context, appState, child) {
                    final isBookmarked = appState.bookmarkedProductIds.contains(product.id);
                    return IconButton(
                      onPressed: () {
                        appState.toggleBookmark(product.id);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isBookmarked ? 'Removed from Wishlist' : 'Added to Wishlist'), duration: const Duration(milliseconds: 1000)));
                      },
                      icon: Icon(isBookmarked ? Icons.bookmark_added_rounded : Icons.bookmark_add_rounded, color: isBookmarked ? theme.colorScheme.secondary : theme.colorScheme.onSurface.withAlpha(179)),
                      style: IconButton.styleFrom(side: BorderSide(color: Colors.grey.shade400, width: 1), padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text(priceText, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.tertiary)),
                const SizedBox(width: 12),
                const Icon(Icons.star, color: Colors.yellowAccent, size: 22),
                const SizedBox(width: 4),
                Flexible(child: Text('${product.rating} (${product.reviewCount} Reviews)', style: TextStyle(color: isDarkTheme ? Colors.grey.shade400 : Colors.grey.shade700, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis, maxLines: 1)),
              ],
            ),
            const SizedBox(height: 16),
            Text(product.details, style: TextStyle(color: isDarkTheme ? Colors.white70 : Colors.black87, fontSize: 15)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8.0,
              children: product.tags.map((tag) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: tag == 'STEM' || tag == 'Tech' ? Colors.teal : Colors.indigo, borderRadius: BorderRadius.circular(30)), child: Text(tag, style: const TextStyle(color: Colors.white)))).toList(),
            ),
            const SizedBox(height: 28),
            Text('User Reviews (${product.reviewCount})', style: TextStyle(color: theme.colorScheme.secondary, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Column(
              children: List.generate(effectiveReviewsCount, (index) => Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: theme.cardColor.withAlpha(isDarkTheme ? 128 : 255), borderRadius: BorderRadius.circular(12)), child: ListTile(leading: Icon(Icons.account_circle, color: isDarkTheme ? Colors.white54 : theme.colorScheme.primary), title: Text("User ${index + 1}"), subtitle: const Text('Great notes!'), trailing: Text('${(product.rating - 0.1).toStringAsFixed(1)} ★', style: const TextStyle(color: Colors.amberAccent))))),
            ),
            if (canShowAll && !_showAllReviews)
              TextButton(onPressed: () => setState(() => _showAllReviews = true), child: Text('View All Reviews', style: TextStyle(color: theme.colorScheme.secondary))),
            if (_showAllReviews)
              TextButton(onPressed: () => setState(() => _showAllReviews = false), child: Text('Hide Extra Reviews', style: TextStyle(color: theme.colorScheme.secondary))),
            const SizedBox(height: 42),
          ],
        ),
      ),
    );
  }
}
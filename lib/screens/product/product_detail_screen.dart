// Auto-generated screen from main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock_data.dart';
import '../../state/app_state.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final productId =
        int.tryParse(appState.selectedProductId ?? '') ??
        1; // Default to product 1
    final product = dummyProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => dummyProducts.first,
    );

    final isOwned = appState.bookmarkedProductIds.contains(product.id);
    final isBookmarked =
        isOwned; // For the prototype, owned means bookmarked/in library
    final priceText = product.isFree ? 'FREE' : '${product.price} Tokens';
    // Define backupColor locally
    final Color backupColor = const Color(0xFF14B8A6);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1520),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            // Back Button
            TextButton.icon(
              onPressed: appState.navigateBack,
              icon: Icon(Icons.arrow_back, color: Colors.white70, size: 22),
              label: Text('Back', style: TextStyle(color: Colors.white70)),
            ),
            const SizedBox(height: 18),
            // Book Icon Block
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Color(0xFF4C4435),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  Icons.menu_book,
                  size: 70,
                  color: Color(0xFFC6A153),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Read Document Action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => appState.navigate(
                  AppScreen.reading,
                  id: product.id.toString(),
                ),
                icon: Icon(Icons.menu_book, color: Colors.black),
                label: Text(
                  'Read Document',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF24E3C6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked
                        ? theme.colorScheme.secondary
                        : Colors.grey,
                  ),
                  onPressed: () => appState.toggleBookmark(product.id),
                  splashRadius: 24,
                ),
                IconButton(
                  icon: Icon(Icons.shopping_cart_outlined, color: Colors.amber),
                  onPressed: () => appState.addToCart(product),
                  splashRadius: 24,
                ),
                IconButton(
                  icon: Icon(Icons.share_outlined, color: Colors.white54),
                  onPressed: () {},
                  splashRadius: 24,
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Title & Price
            Text(
              'Calculus I - Integrals',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '50 Tokens',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.star, color: Colors.yellowAccent, size: 22),
                SizedBox(width: 4),
                Text(
                  '4.8 (88 Reviews)',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Metadata Row
            Text(
              'Type: Notes    Author: Dr. Emily Carter',
              style: TextStyle(color: Colors.white60),
            ),
            SizedBox(height: 2),
            Text(
              'Category: Math    Pages: 45',
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 14),
            // Description
            Text(
              product.details,
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            SizedBox(height: 10),
            // Pill-Shaped Tags
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "High-Demand",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text("STEM", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 28),
            // Reviews Section
            Text(
              'User Reviews (88)',
              style: TextStyle(
                color: Color(0xFFD49AF9),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            // Review Cards
            Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Color(0xFF181F2A),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: ListTile(
                leading: Icon(Icons.account_circle, color: Colors.white54),
                title: Text(
                  "Alex M.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  'The best notes I\'ve bought! Super clear and highly detailed diagrams.',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: Text(
                  "5.0 ★",
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Color(0xFF181F2A),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: ListTile(
                leading: Icon(Icons.account_circle, color: Colors.white54),
                title: Text(
                  "Sarah K.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  'Great content, but wish there were more practice examples. Still worth the tokens!',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: Text(
                  "4.0 ★",
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "View All Reviews",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            SizedBox(height: 42),
          ],
        ),
      ),
    );
  }
}

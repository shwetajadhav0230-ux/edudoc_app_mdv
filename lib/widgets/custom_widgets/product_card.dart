import 'package:flutter/material.dart';
import '../../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.grey[900],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              color: Colors.grey[800],
              child: Icon(Icons.image, size: 50, color: Colors.grey[700]),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('${product.price} Tokens', style: const TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}

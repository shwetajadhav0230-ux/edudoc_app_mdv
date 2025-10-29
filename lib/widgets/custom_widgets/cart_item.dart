import 'package:flutter/material.dart';
import '../../models/product.dart';

class CartItem extends StatelessWidget {
  final Product product;

  const CartItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.shopping_bag, size: 50, color: Theme.of(context).colorScheme.primary),
      title: Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${product.price} Tokens'),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';

class CartItem extends StatelessWidget {
  final Product product;

  const CartItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return ListTile(
      leading: Icon(
        Icons.shopping_bag,
        size: 50,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        product.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('${product.price} Tokens'),
      // --- ADDED: Delete Button ---
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: () {
          // Call the removeCartItem method in AppState
          appState.removeCartItem(product.id);

          // Optional: Show a confirmation Snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.title} removed from cart.'),
              duration: const Duration(milliseconds: 800),
            ),
          );
        },
      ),
      // --- END ADDED ---
    );
  }
}
// Auto-generated screen from main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../widgets/custom_widgets/cart_item.dart';
import '../../widgets/custom_widgets/summary_row.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final totalCost = appState.cartItems.fold(
      0,
      (sum, item) => sum + item.price,
    );
    final canCheckout =
        totalCost <= appState.walletTokens && appState.cartItems.isNotEmpty;

    return Scaffold(
      // Wrapped in Scaffold to allow for AppBar
      appBar: AppBar(
        // Added Back Button logic
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              appState.navigateBack(), // Uses navigation logic from app_state
        ),
        title: Text('Shopping Cart', style: theme.textTheme.titleLarge),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // This Column ensures everything is stacked vertically
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The title "Shopping Cart" is now in the AppBar, removed here

            // Re-adding a small space if needed, though the AppBar spacing might suffice
            // const SizedBox(height: 16),

            // --- Cart Items List ---
            // This Column lists the cart items. It is INSIDE the main Column.
            appState.cartItems.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 48.0),
                      child: Text('Your cart is empty.'),
                    ),
                  )
                : Column(
                    children: appState.cartItems
                        .map((item) => CartItem(product: item))
                        .toList(),
                  ),

            const SizedBox(height: 24), // Space between items and summary
            // --- Summary Card ---
            // This Card is now AFTER the cart items in the main Column
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        color: theme.colorScheme.primary, // Blue color
                      ),
                    ),
                    const SizedBox(height: 8),
                    SummaryRow(
                      label: 'Items (${appState.cartItems.length})',
                      value: '$totalCost Tokens',
                    ),
                    SummaryRow(
                      label: 'Tax/Fees (Simulated)',
                      value: '0 Tokens',
                    ),
                    const Divider(),
                    SummaryRow(
                      label: 'Total Tokens Required',
                      value: '$totalCost Tokens',
                      isTotal: true,
                    ),
                    const SizedBox(height: 16),

                    // --- Gradient Button ---
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withAlpha(77),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: canCheckout ? appState.checkout : null,
                        icon: const Icon(
                          Icons.description, // Icon from image
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Proceed to Checkout',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                    ),

                    // --- End Button ---
                    if (!canCheckout && appState.cartItems.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Center(
                          child: Text(
                            'Insufficient tokens.',
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

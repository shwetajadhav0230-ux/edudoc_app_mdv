import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../widgets/custom_widgets/cart_item.dart';
import '../../widgets/custom_widgets/summary_row.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _showPINConfirmationDialog(BuildContext context, int totalCost) {
    _pinController.clear();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String? localErrorText;
        final appState = Provider.of<AppState>(dialogContext, listen: false);

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setLocalState) {
            return AlertDialog(
              title: const Text('Confirm Purchase'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Enter your 4-digit Transaction PIN to confirm the purchase of $totalCost Tokens.'),
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final enteredPin = _pinController.text;
                    // Calls the verification logic in AppState
                    bool isValid = await appState.verifyTransactionPin(enteredPin);

                    if (isValid) {
                      Navigator.of(context).pop();
                      appState.checkout(); //
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Purchase completed!')),
                      );
                    } else {
                      setLocalState(() => localErrorText = 'Incorrect PIN.');
                    }
                  },
                  child: const Text('Confirm'),
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
    final theme = Theme.of(context);
    final totalCost = appState.cartItems.fold(0, (sum, item) => sum + item.price);
    final canCheckout = totalCost <= appState.walletTokens && appState.cartItems.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.navigateBack(),
        ),
        title: Text('Shopping Cart', style: theme.textTheme.titleLarge),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            appState.cartItems.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 48.0), child: Text('Your cart is empty.')))
                : Column(children: appState.cartItems.map((item) => CartItem(product: item)).toList()),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SummaryRow(label: 'Items (${appState.cartItems.length})', value: '$totalCost Tokens'),
                    const Divider(),
                    SummaryRow(label: 'Total Required', value: '$totalCost Tokens', isTotal: true),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: canCheckout
                          ? () {
                        if (!appState.isTransactionPinSet) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Set a Transaction PIN in Settings first.'), backgroundColor: Colors.orange),
                          );
                        } else {
                          _showPINConfirmationDialog(context, totalCost);
                        }
                      }
                          : null,
                      child: const Text('Proceed to Checkout'),
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
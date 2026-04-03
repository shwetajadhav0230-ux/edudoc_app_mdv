import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/payment_service.dart';
import '../state/app_state.dart';

// ✅ ONLY "BuyTokensModal" remains here.
// The old navigation code has been deleted to prevent the crash.

class BuyTokensModal extends StatelessWidget {
  const BuyTokensModal({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final theme = Theme.of(context);
    final packages = [100, 500, 1000, 2500];

    return AlertDialog(
      title: Text('Purchase Tokens', style: theme.textTheme.titleLarge),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.5),
          itemCount: packages.length,
          itemBuilder: (context, index) {
            final amount = packages[index];
            return GestureDetector(
              onTap: () {
                final user = appState.currentUser;
                Navigator.of(context).pop();
                PaymentService().payForTokens(context, tokens: amount, contact: user.phoneNumber, email: user.email);
              },
              child: Card(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$amount', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.tertiary)),
                      const Text('Tokens', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))],
    );
  }
}
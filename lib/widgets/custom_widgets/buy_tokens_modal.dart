import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

class BuyTokensModal extends StatelessWidget {
  const BuyTokensModal({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final theme = Theme.of(context);
    final packages = [100, 500, 1000, 2500];

    return AlertDialog(
      title: Text(
        'Purchase Tokens',
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
          ),
          itemCount: packages.length,
          itemBuilder: (context, index) {
            final amount = packages[index];
            return GestureDetector(
              onTap: () {
                appState.buyTokens(amount);
                Navigator.of(context).pop();
              },
              child: Card(
                color: amount != 500
                    ? theme.cardColor
                    : theme.colorScheme.secondary.withOpacity(0.1),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$amount',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      const Text('Tokens', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        '\$${(amount / 100).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

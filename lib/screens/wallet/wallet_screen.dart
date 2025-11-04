import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../state/app_state.dart';
import '../../widgets/custom_widgets/buy_tokens_modal.dart' show BuyTokensModal;
// NOTE: Assuming BuyTokensModal is imported/accessible

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    // Define backupColor locally
    final Color backupColor = const Color(0xFF14B8A6);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back to Home Button in the same line as the heading
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => appState.navigate(AppScreen.home),
                icon: Icon(
                  Icons.arrow_back,
                  color: theme.textTheme.bodyMedium?.color,
                  size: 20,
                ),
                label: Text(
                  'Token Wallet',
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
                ),
              ),
              // REMOVED: The section that displayed current tokens (e.g., "450 🪙") in the header line.
            ],
          ),
          const SizedBox(height: 16),

          // Current Balance Card
          Card(
            color: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row for 'Balance' and 'Buy Tokens' button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Balance',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 16,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => const BuyTokensModal(),
                        ),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Buy Tokens',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // MODIFIED: Display balance with icon (icon moved to be first)
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on, // Chrome yellow coins stack icon
                        color: theme
                            .colorScheme
                            .tertiary, // Using the tertiary color for the icon
                        size: 40,
                      ),
                      const SizedBox(
                        width: 8,
                      ), // Spacing between icon and number
                      Text(
                        '${appState.walletTokens}',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Transaction History
          Text(
            'Transaction History',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Column(
            children: transactionHistory
                .map(
                  (tx) => Card(
                child: ListTile(
                  leading: Icon(
                    tx.type == 'Credit'
                        ? Icons.add_circle
                        : Icons.remove_circle,
                    color: tx.type == 'Credit' ? backupColor : Colors.red,
                  ),
                  title: Text(tx.description),
                  subtitle: Text(tx.date),
                  trailing: Text(
                    '${tx.type == 'Credit' ? '+' : '-'}${tx.amount} T.',
                    style: TextStyle(
                      color: tx.type == 'Credit' ? backupColor : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
                .toList(),
          ),
        ],
      ),
    );
  }
}

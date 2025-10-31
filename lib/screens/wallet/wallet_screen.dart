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
          // NEW: Back to Home Button in the same line as the heading
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
              // Displaying current tokens in the header line as a separate element
              Row(
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: theme.colorScheme.tertiary,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${appState.walletTokens}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current Balance Card (Simplified structure since details are in the Transaction History)
          Card(
            color: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Balance',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${appState.walletTokens} Tokens',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.tertiary,
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

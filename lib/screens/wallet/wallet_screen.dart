// Auto-generated screen from main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../widgets/common_widgets.dart';
import '../../data/mock_data.dart';
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
          Text(
            'Token Wallet',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 16),
          // Current Balance Card
          Card(
            color: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Token Balance',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.monetization_on,
                            color: theme.colorScheme.tertiary,
                            size: 40,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${appState.walletTokens}',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
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

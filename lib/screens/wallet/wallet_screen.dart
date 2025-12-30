// lib/screens/wallet/wallet_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../widgets/custom_widgets/buy_tokens_modal.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet'), elevation: 0),
      body: RefreshIndicator(
        // ADDED: Link to the new refresh method
        onRefresh: () => appState.refreshWalletData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text('Available Tokens', style: TextStyle(color: Colors.white70)),
                    Text('${appState.walletTokens}',
                        style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        builder: (_) => const BuyTokensModal(),
                      ),
                      child: const Text('Top Up Tokens'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Transaction History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),

              // ADDED: Dynamic List from AppState
              if (appState.transactionHistory.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text('No transactions found.'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appState.transactionHistory.length,
                  itemBuilder: (context, index) {
                    final tx = appState.transactionHistory[index];
                    final isCredit = tx.type == 'Credit';
                    return ListTile(
                      leading: Icon(isCredit ? Icons.add_circle : Icons.remove_circle,
                          color: isCredit ? Colors.green : Colors.red),
                      title: Text(tx.description),
                      subtitle: Text(tx.date),
                      trailing: Text('${isCredit ? "+" : ""}${tx.amount} T',
                          style: TextStyle(fontWeight: FontWeight.bold,
                              color: isCredit ? Colors.green : Colors.red)),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
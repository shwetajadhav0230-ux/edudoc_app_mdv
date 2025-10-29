// Auto-generated screen from main.dart

import 'package:flutter/material.dart';

import '../../data/mock_data.dart';


class UserActivityScreen extends StatelessWidget {
  const UserActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Define backupColor locally
    final Color backupColor = const Color(0xFF14B8A6);

    final userActivity = transactionHistory
        .where((tx) => tx.type == 'Debit' || tx.type == 'Download')
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Purchases & Downloads',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 16),
          if (userActivity.isEmpty)
            const Center(child: Text('No recent activity.')),
          ...userActivity.map(
            (tx) => Card(
              child: ListTile(
                leading: Icon(
                  tx.type == 'Debit' ? Icons.shopping_bag : Icons.download,
                  color: tx.type == 'Debit'
                      ? theme.colorScheme.secondary
                      : backupColor,
                ),
                title: Text(tx.description),
                subtitle: Text(tx.date),
                trailing: Text(
                  tx.type == 'Debit' ? '-${tx.amount} T.' : 'FREE',
                  style: TextStyle(
                    color: tx.type == 'Debit' ? Colors.red : backupColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

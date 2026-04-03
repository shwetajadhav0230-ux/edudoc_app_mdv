// lib/screens/profile/user_activity_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

class UserActivityScreen extends StatefulWidget {
  const UserActivityScreen({super.key});

  @override
  State<UserActivityScreen> createState() => _UserActivityScreenState();
}

class _UserActivityScreenState extends State<UserActivityScreen> {
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final Color backupColor = const Color(0xFF14B8A6);

    final userActivity = appState.transactionHistory.where((tx) {
      if (_activeFilter == 'All') {
        return tx.type == 'Debit' || tx.type == 'Download';
      }
      if (_activeFilter == 'Purchases') {
        return tx.type == 'Debit';
      }
      if (_activeFilter == 'Downloads') {
        return tx.type == 'Download';
      }
      return false;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Purchases & Downloads'),
        leading: BackButton(
          onPressed: () => Provider.of<AppState>(context, listen: false).navigateBack(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Filter Chips
            Wrap(
              spacing: 8.0,
              children: ['All', 'Purchases', 'Downloads'].map((filter) {
                final isSelected = _activeFilter == filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _activeFilter = filter;
                      });
                    }
                  },
                  selectedColor: theme.colorScheme.primary,
                  backgroundColor: theme.cardColor,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : theme.textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            if (userActivity.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Text('No activity found for this filter.'),
                ),
              ),
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
      ),
    );
  }
}
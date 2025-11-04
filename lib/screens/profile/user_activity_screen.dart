// lib/screens/profile/user_activity_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- ADDED
import '../../state/app_state.dart'; // <-- ADDED

// import '../../data/mock_data.dart'; // <-- REMOVED

// --- MODIFIED: Converted to StatefulWidget ---
class UserActivityScreen extends StatefulWidget {
  const UserActivityScreen({super.key});

  @override
  State<UserActivityScreen> createState() => _UserActivityScreenState();
}

class _UserActivityScreenState extends State<UserActivityScreen> {
  // --- NEW: State variable to track the active filter ---
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    // --- MODIFICATION ---
    final appState = Provider.of<AppState>(context); // <-- Get AppState
    final theme = Theme.of(context);
    // Define backupColor locally
    final Color backupColor = const Color(0xFF14B8A6);

    // --- MODIFICATION ---
    final userActivity = appState.transactionHistory.where((tx) { // <-- Read from appState
      if (_activeFilter == 'All') {
        return tx.type == 'Debit' || tx.type == 'Download';
      }
      if (_activeFilter == 'Purchases') {
        return tx.type == 'Debit';
      }
      if (_activeFilter == 'Downloads') {
        return tx.type == 'Download';
      }
      return false; // Default case
    }).toList();

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

          // --- NEW: Filter Chips ---
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
          // --- END NEW ---

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
    );
  }
}
// Auto-generated screen from main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock_data.dart';
import '../../state/app_state.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find Your Next Document',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 16),
          // Search Input
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Search notes, books, or authors...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Filters',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: ['All', 'Tech', 'Math', 'History', 'Free', 'Premium']
                .map(
                  (label) => Chip(
                    label: Text(label),
                    // Used MaterialStateProperty to set color on chips
                    color: WidgetStateProperty.resolveWith<Color>((
                      Set<WidgetState> states,
                    ) {
                      if (label == 'All') {
                        return theme.colorScheme.primary;
                      }
                      return theme.cardColor;
                    }),
                    labelStyle: TextStyle(
                      color: label == 'All'
                          ? Colors.white
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          // Search Results
          Text(
            'Results (Mock)',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          // Use a simple list for results, similar to home page listing
          ...dummyProducts
              .take(4)
              .map(
                (p) => Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.file_copy,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(p.title),
                    subtitle: Text(p.author),
                    trailing: Text(
                      '${p.price} T.',
                      style: TextStyle(color: theme.colorScheme.tertiary),
                    ),
                    onTap: () => appState.navigate(
                      AppScreen.productDetails,
                      id: p.id.toString(),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

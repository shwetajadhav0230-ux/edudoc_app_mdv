import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../state/app_state.dart';
// Assuming ProductCard is available to display results visually
// import '../../widgets/custom_widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // State variables for dynamic filtering
  String _searchQuery = '';
  String _selectedCategory = 'All';
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    // Initialize controller and add a listener for live updates
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // --- 1. Filtering Logic ---
    final filteredProducts = dummyProducts.where((p) {
      final matchesQuery =
          p.title.toLowerCase().contains(_searchQuery) ||
          p.author.toLowerCase().contains(_searchQuery) ||
          p.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));

      final matchesCategory =
          _selectedCategory == 'All' ||
          p.category == _selectedCategory ||
          (_selectedCategory == 'Free' && p.isFree) ||
          (_selectedCategory == 'Premium' && p.price > 0);

      return matchesQuery && matchesCategory;
    }).toList();

    return Scaffold(
      // <--- WRAPPED IN SCAFFOLD
      appBar: AppBar(
        // <--- IMPLEMENTED STANDARD BACK BUTTON
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.navigateBack(),
        ),
        // Moved the main title here
        title: Text(
          'Find Your Next Document',
          style: theme.textTheme.titleLarge,
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // REMOVED: Manual TextButton.icon for navigation
            // REMOVED: Redundant Title Text widget

            // Added space for visual separation below the AppBar (if needed)
            const SizedBox(height: 8),

            // Search Input (Connected to Controller and Clear Button)
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search notes, books, or authors...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- 2. Filters ---
            Text(
              'Filters',
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 8.0,
                children: ['All', 'Tech', 'Math', 'History', 'Free', 'Premium']
                    .map(
                      (label) => ChoiceChip(
                        label: Text(label),
                        selected: _selectedCategory == label,
                        onSelected: (_) => _selectCategory(label),
                        selectedColor: theme.colorScheme.primary,
                        backgroundColor: theme.cardColor,
                        labelStyle: TextStyle(
                          color: _selectedCategory == label
                              ? Colors.white
                              : theme.textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),

            // --- 3. Search Results ---
            Text(
              'Results (${filteredProducts.length})',
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),

            if (filteredProducts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Text(
                    'No documents found matching your criteria.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              // Display filtered results
              ...filteredProducts.map(
                (p) => Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    leading: Icon(
                      p.type == 'Books' ? Icons.book : Icons.file_copy,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      p.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('by ${p.author} - ${p.category}'),
                    trailing: Text(
                      p.isFree ? 'FREE' : '${p.price} T.',
                      style: TextStyle(
                        color: p.isFree
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
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
      ),
    );
  }
}

// lib/screens/search/search_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/offer.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  late final TextEditingController _searchController;

  final List<Map<String, dynamic>> _appShortcuts = [
    {'title': 'Wallet & Tokens', 'icon': Icons.account_balance_wallet, 'screen': AppScreen.wallet},
    {'title': 'My Library', 'icon': Icons.library_books, 'screen': AppScreen.library},
    {'title': 'App Settings', 'icon': Icons.settings, 'screen': AppScreen.settings},
    {'title': 'Profile Settings', 'icon': Icons.person, 'screen': AppScreen.profileEdit},
    {'title': 'Cart / Checkout', 'icon': Icons.shopping_cart, 'screen': AppScreen.cart},
    {'title': 'Help & Support', 'icon': Icons.help_outline, 'screen': AppScreen.helpSupport},
    {'title': 'About EduDoc', 'icon': Icons.info_outline, 'screen': AppScreen.about},
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).loadSearchHistory();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _searchQuery = _searchController.text.toLowerCase());
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

    final filteredShortcuts = _appShortcuts.where((s) {
      if (_searchQuery.isEmpty) return false;
      return s['title'].toLowerCase().contains(_searchQuery);
    }).toList();

    final filteredProducts = appState.products.where((p) {
      if (_searchQuery.isEmpty) return false;
      final matchesQuery = p.title.toLowerCase().contains(_searchQuery) ||
          p.author.toLowerCase().contains(_searchQuery);
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();

    final filteredOffers = appState.offers.where((o) {
      if (_searchQuery.isEmpty) return false;
      return o.title.toLowerCase().contains(_searchQuery);
    }).toList();

    final bool hasResults = filteredShortcuts.isNotEmpty || filteredProducts.isNotEmpty || filteredOffers.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => appState.navigateBack()),
        title: const Text('Universal Search'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search across EduDoc...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch)
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            if (_searchQuery.isEmpty)
              _buildInitialState(appState, theme)
            else if (!hasResults)
              _buildNoResultsState(theme)
            else
              _buildResultsList(filteredShortcuts, filteredProducts, filteredOffers, appState, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState(AppState appState, ThemeData theme) {
    return Column(
      children: [
        if (appState.searchHistory.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Searches', style: theme.textTheme.titleMedium),
              TextButton(onPressed: () => appState.clearSearchHistory(), child: const Text('Clear')),
            ],
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: appState.searchHistory.map((query) => InputChip( // ADDED: Changed to InputChip
              label: Text(query),
              onPressed: () {
                _searchController.text = query;
                _onSearchChanged();
              },
              // ADDED: Specific deletion logic for this query
              onDeleted: () => appState.removeFromSearchHistory(query),
              deleteIcon: const Icon(Icons.cancel, size: 16),
            )).toList(),
          ),
        ],
        const Padding(
          padding: EdgeInsets.only(top: 60),
          child: Opacity(opacity: 0.5, child: Text('Find documents, settings, or help items.')),
        )
      ],
    );
  }

  Widget _buildNoResultsState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.2)),
            const SizedBox(height: 16),
            const Text('No matches found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Try adjusting your search or filters.', textAlign: TextAlign.center),
            TextButton(onPressed: _clearSearch, child: const Text('Clear Search')),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(List shortcuts, List products, List offers, AppState appState, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (shortcuts.isNotEmpty) ...[
          const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold)),
          ...shortcuts.map((s) => ListTile(
              leading: Icon(s['icon']), title: Text(s['title']),
              onTap: () => appState.navigate(s['screen']))),
        ],
        if (products.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Documents (${products.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
          ...products.map((p) => ListTile(
              title: Text(p.title), subtitle: Text(p.author),
              onTap: () => appState.navigate(AppScreen.productDetails, id: p.id.toString()))),
        ],
      ],
    );
  }
}
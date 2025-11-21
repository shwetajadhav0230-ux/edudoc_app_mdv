import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../data/mock_data.dart'; // REMOVED
import '../../models/offer.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';

// ... [Keep _SearchableAppRoute class unchanged] ...
class _SearchableAppRoute {
  final String title;
  final String description;
  final List<String> keywords;
  final IconData icon;
  final AppScreen destination;

  _SearchableAppRoute({
    required this.title,
    required this.description,
    required this.keywords,
    required this.icon,
    required this.destination,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  late final TextEditingController _searchController;

  // ... [Keep _searchableRoutes unchanged] ...
  final List<_SearchableAppRoute> _searchableRoutes = [
    _SearchableAppRoute(title: 'Token Wallet', description: 'View balance', keywords: ['token', 'wallet'], icon: Icons.monetization_on, destination: AppScreen.wallet),
    _SearchableAppRoute(title: 'My Library', description: 'Access purchased docs', keywords: ['library', 'owned'], icon: Icons.library_books, destination: AppScreen.library),
    _SearchableAppRoute(title: 'App Settings', description: 'Theme & Security', keywords: ['settings', 'theme'], icon: Icons.settings, destination: AppScreen.settings),
  ];

  @override
  void initState() {
    super.initState();
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

  // Helper methods (omitted for brevity, but they remain the same)
  Widget _buildProductTile(Product p, AppState appState, ThemeData theme) {
    return Card(
      child: ListTile(
        title: Text(p.title), subtitle: Text(p.author),
        trailing: Text(p.isFree ? 'FREE' : '${p.price} T.'),
        onTap: () => appState.navigate(AppScreen.productDetails, id: p.id.toString()),
      ),
    );
  }

  Widget _buildOfferTile(Offer o, AppState appState, ThemeData theme) {
    return Card(
      child: ListTile(
        title: Text(o.title), subtitle: Text('Bundle: ${o.discount} Off'),
        onTap: () => appState.navigate(AppScreen.offerDetails, id: o.id.toString()),
      ),
    );
  }

  Widget _buildAppRouteTile(_SearchableAppRoute r, AppState appState, ThemeData theme) {
    return Card(child: ListTile(title: Text(r.title), leading: Icon(r.icon), onTap: () => appState.navigate(r.destination)));
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // --- 1. Filtering Logic (Products) ---
    // USE appState.products
    final filteredProducts = appState.products.where((p) {
      if (_searchQuery.isEmpty) return false;
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

    // --- 2. Filtering Logic (Offers) ---
    // USE appState.offers
    final filteredOffers = appState.offers.where((o) {
      if (_searchQuery.isEmpty) return false;
      final matchesQuery = o.title.toLowerCase().contains(_searchQuery);
      return matchesQuery;
    }).toList();

    // --- 3. Filtering App Routes ---
    List<_SearchableAppRoute> filteredAppRoutes = [];
    if (_searchQuery.isNotEmpty) {
      filteredAppRoutes = _searchableRoutes.where((route) {
        final matchesQuery =
            route.title.toLowerCase().contains(_searchQuery) ||
                route.keywords.any((k) => k.toLowerCase().contains(_searchQuery));
        return matchesQuery;
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => appState.navigateBack()),
        title: Text('Universal Search', style: theme.textTheme.titleLarge),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Search products, settings, authors...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: _clearSearch) : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            Text('Filters', style: theme.textTheme.titleLarge?.copyWith(fontSize: 20)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 8.0,
                children: ['All', 'Tech', 'Math', 'History', 'Free', 'Premium'].map((label) => ChoiceChip(
                  label: Text(label),
                  selected: _selectedCategory == label,
                  onSelected: (_) => _selectCategory(label),
                )).toList(),
              ),
            ),
            const SizedBox(height: 24),
            if (_searchQuery.isEmpty)
              const Center(child: Text('Search for products or bundles...'))
            else if (filteredProducts.isEmpty && filteredOffers.isEmpty && filteredAppRoutes.isEmpty)
              const Center(child: Text('No items found matching your criteria.'))
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (filteredAppRoutes.isNotEmpty) ...[
                    Text('App Navigation', style: theme.textTheme.titleLarge?.copyWith(fontSize: 20)),
                    const SizedBox(height: 8),
                    ...filteredAppRoutes.map((r) => _buildAppRouteTile(r, appState, theme)),
                  ],
                  if (filteredProducts.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Products (${filteredProducts.length})', style: theme.textTheme.titleLarge?.copyWith(fontSize: 20)),
                    const SizedBox(height: 8),
                    ...filteredProducts.map((p) => _buildProductTile(p, appState, theme)),
                  ],
                  if (filteredOffers.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Offers (${filteredOffers.length})', style: theme.textTheme.titleLarge?.copyWith(fontSize: 20)),
                    const SizedBox(height: 8),
                    ...filteredOffers.map((o) => _buildOfferTile(o, appState, theme)),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
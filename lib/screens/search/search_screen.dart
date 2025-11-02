// lib/screens/search/search_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../models/offer.dart'; // <-- IMPORT Offer model
import '../../models/product.dart'; // <-- IMPORT Product model
import '../../state/app_state.dart';

// --- NEW: Data class for searchable app routes/settings ---
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
// --- END NEW ---

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

  // --- NEW: List of searchable app routes based on profile_screen.dart ---
  final List<_SearchableAppRoute> _searchableRoutes = [
    _SearchableAppRoute(
      title: 'Token Wallet & History',
      description: 'View your balance and transactions',
      keywords: ['token', 'wallet', 'history', 'purchase', 'balance', 'buy'],
      icon: Icons.monetization_on,
      destination: AppScreen.wallet,
    ),
    _SearchableAppRoute(
      title: 'My Wishlisted',
      description: 'See documents you\'ve saved for later',
      keywords: ['wishlist', 'bookmarks', 'saved', 'later'],
      icon: Icons.bookmark,
      destination: AppScreen.bookmarks,
    ),
    _SearchableAppRoute(
      title: 'My Digital Library',
      description: 'Access all your purchased documents',
      keywords: ['library', 'owned', 'my documents', 'books', 'notes'],
      icon: Icons.library_books,
      destination: AppScreen.library,
    ),
    _SearchableAppRoute(
      title: 'My Activity & Purchases',
      description: 'Review your download and purchase history',
      keywords: ['activity', 'purchases', 'downloads', 'history'],
      icon: Icons.show_chart,
      destination: AppScreen.userActivity,
    ),
    _SearchableAppRoute(
      title: 'App Settings',
      description: 'Manage theme, security, and notifications',
      keywords: ['settings', 'options', 'dark mode', 'theme', 'password', 'security'],
      icon: Icons.settings,
      destination: AppScreen.settings,
    ),
    _SearchableAppRoute(
      title: 'Edit Profile',
      description: 'Update your name, email, or profile picture',
      keywords: ['profile', 'edit', 'name', 'email', 'avatar', 'picture'],
      icon: Icons.edit,
      destination: AppScreen.profileEdit,
    ),
    _SearchableAppRoute(
      title: 'My Account / Profile',
      description: 'Go to your main account page',
      keywords: ['profile', 'account', 'my account'],
      icon: Icons.person,
      destination: AppScreen.profile,
    ),
  ];
  // --- END NEW ---

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

  // --- Helper method to build Product tiles ---
  Widget _buildProductTile(
      Product p, AppState appState, ThemeData theme) {
    return Card(
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
    );
  }

  // --- Helper method to build Offer tiles ---
  Widget _buildOfferTile(Offer o, AppState appState, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(
          Icons.local_offer,
          color: theme.colorScheme.secondary,
        ),
        title: Text(
          o.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Bundle: ${o.discount} Off'),
        trailing: Text(
          o.tokenPrice == 0 ? 'FREE' : '${o.tokenPrice} T.',
          style: TextStyle(
            color: o.tokenPrice == 0
                ? theme.colorScheme.secondary
                : theme.colorScheme.tertiary,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => appState.navigate(
          AppScreen.offerDetails,
          id: o.id.toString(),
        ),
      ),
    );
  }

  // --- NEW: Helper method to build App Route tiles ---
  Widget _buildAppRouteTile(
      _SearchableAppRoute route, AppState appState, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(
          route.icon,
          color: theme.colorScheme.tertiary, // Use a distinct color
        ),
        title: Text(
          route.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(route.description),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => appState.navigate(route.destination),
      ),
    );
  }
  // --- END NEW ---

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // --- 1. Filtering Logic (Products) ---
    final filteredProducts = dummyProducts.where((p) {
      // Don't search if query is empty
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
    final filteredOffers = dummyOffers.where((o) {
      if (_searchQuery.isEmpty) return false;
      final matchesQuery = o.title.toLowerCase().contains(_searchQuery);

      // Filters don't apply to offers in this logic, but you could add them
      final matchesCategory = _selectedCategory == 'All' ||
          _selectedCategory == 'Premium' ||
          _selectedCategory == 'Free';
      return matchesQuery && matchesCategory;
    }).toList();

    // --- 3. NEW: Filtering Logic (App Routes/Settings) ---
    // Only search routes if there is a query. This search is independent
    // of the category filter chips.
    List<_SearchableAppRoute> filteredAppRoutes = [];
    if (_searchQuery.isNotEmpty) {
      filteredAppRoutes = _searchableRoutes.where((route) {
        final matchesQuery =
            route.title.toLowerCase().contains(_searchQuery) ||
                route.keywords.any((k) => k.toLowerCase().contains(_searchQuery));
        return matchesQuery;
      }).toList();
    }
    // --- END NEW ---

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.navigateBack(),
        ),
        title: Text(
          'Universal Search', // <-- Updated title
          style: theme.textTheme.titleLarge,
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Search Input
            TextFormField(
              controller: _searchController,
              autofocus: true, // <-- Make search start immediately
              decoration: InputDecoration(
                labelText: 'Search products, settings, authors...',
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

            // --- Filters ---
            Text(
              'Filters (for Products/Offers)', // <-- Clarified filter scope
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

            // --- REBUILT: Search Results ---
            if (_searchQuery.isEmpty) // <-- Show prompt if search is empty
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Text(
                    'Search for products, bundles, or settings...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            // --- UPDATED: Check all three lists for "no results" ---
            else if (filteredProducts.isEmpty &&
                filteredOffers.isEmpty &&
                filteredAppRoutes.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Text(
                    'No items found matching your criteria.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- NEW: App Navigation Section ---
                  if (filteredAppRoutes.isNotEmpty) ...[
                    Text(
                      'App Navigation & Settings',
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    ...filteredAppRoutes.map(
                          (r) => _buildAppRouteTile(r, appState, theme),
                    ),
                  ],
                  // --- END NEW ---

                  // --- Products Section ---
                  if (filteredProducts.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Products (${filteredProducts.length})',
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    ...filteredProducts.map(
                          (p) => _buildProductTile(p, appState, theme),
                    ),
                  ],

                  // --- Offers Section ---
                  if (filteredOffers.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Offers & Bundles (${filteredOffers.length})',
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    ...filteredOffers.map(
                          (o) => _buildOfferTile(o, appState, theme),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
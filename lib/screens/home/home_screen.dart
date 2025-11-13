// home_screen.dart

import 'dart:async'; // Import for Timer
// Auto-generated screen from main.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';
import '../../widgets/custom_widgets/library_shelf_card.dart';
// --- Importing all card types used on this screen ---
import '../../widgets/custom_widgets/product_card.dart';

// --- Converted to StatefulWidget ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- State variables for auto-scrolling carousel ---
  late final PageController _offerPageController;
  late final Timer _offerTimer;
  int _currentOfferPage = 0;
  // Get the number of active offers
  late final int _totalOfferPages;

  @override
  void initState() {
    super.initState();

    _totalOfferPages =
        dummyOffers.where((o) => o.status == 'Active').toList().length;

    // Initialize the PageController
    _offerPageController = PageController(viewportFraction: 0.9);

    // Start the 5-second timer
    _offerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _nextPage();
    });
  }

  @override
  void dispose() {
    _offerTimer.cancel();
    _offerPageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    int nextPage = _currentOfferPage + 1;
    if (nextPage >= _totalOfferPages) {
      nextPage = 0; // Loop back to the first page
    }
    _offerPageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 600), // Smooth transition
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    int prevPage = _currentOfferPage - 1;
    if (prevPage < 0) {
      prevPage = _totalOfferPages - 1; // Loop back to the last page
    }
    _offerPageController.animateToPage(
      prevPage,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildOfferCard({
    required BuildContext context,
    required AppState appState,
    required ThemeData theme,
    required String title,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: gradientColors,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArrowButton(BuildContext context,
      {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildPaginationDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8,
      width: isActive ? 16 : 8, // Active dot is wider
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Colors.blueGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // 🚀 FIX APPLIED HERE: Using toLowerCase() for robust, case-insensitive filtering
    final filteredProducts = dummyProducts.where((p) {
      final currentFilter = appState.homeFilter;

      if (currentFilter == 'All') return true;
      if (currentFilter == 'Free') return p.isFree;

      // Compare the lowercase version of the product type to the lowercase version of the filter
      return p.type.toLowerCase() == currentFilter.toLowerCase();
    }).toList();

    final startIndex = (appState.homeCurrentPage - 1) * appState.itemsPerPage;
    final endIndex = min(
      startIndex + appState.itemsPerPage,
      filteredProducts.length,
    );
    final productsToDisplay =
        (filteredProducts.isNotEmpty && startIndex < endIndex)
            ? filteredProducts.sublist(startIndex, endIndex)
            : <Product>[];

    final totalPages = (filteredProducts.length / appState.itemsPerPage).ceil();

    final List<Product> ownedProductsForShelf =
        appState.ownedProductIds.expand((id) {
      try {
        final product = dummyProducts.firstWhere((p) => p.id == id);
        return [product];
      } catch (e) {
        return <Product>[];
      }
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discover Premium Docs',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 24,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // --- Carousel Column ---
          Column(
            children: [
              SizedBox(
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PageView(
                      controller: _offerPageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentOfferPage = index;
                        });
                      },
                      children: [
                        _buildOfferCard(
                          context: context,
                          appState: appState,
                          theme: theme,
                          title: '50% OFF\nBack-to-School Bundle!',
                          gradientColors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                          onTap: () => appState.navigate(AppScreen.offerDetails,
                              id: "201"),
                        ),
                        _buildOfferCard(
                          context: context,
                          appState: appState,
                          theme: theme,
                          title: '20% OFF\nAll Tech Docs Pack!',
                          gradientColors: [
                            Colors.teal.shade400,
                            theme.colorScheme.primary,
                          ],
                          onTap: () => appState.navigate(AppScreen.offerDetails,
                              id: "202"),
                        ),
                      ],
                    ),
                    Positioned(
                      left: 0,
                      child: _buildArrowButton(
                        context,
                        icon: Icons.arrow_back_ios_new,
                        onPressed: _prevPage,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: _buildArrowButton(
                        context,
                        icon: Icons.arrow_forward_ios,
                        onPressed: _nextPage,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalOfferPages, (index) {
                  return _buildPaginationDot(
                    isActive: index == _currentOfferPage,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- My Library Shelf ---
          Text(
            'My Library',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: ownedProductsForShelf.isEmpty
                ? const Center(
                    child: Text(
                      'Your library is empty. Purchase a document to see it here.',
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: ownedProductsForShelf.length,
                    itemBuilder: (context, index) {
                      final product = ownedProductsForShelf[index];
                      return Container(
                        width: 150,
                        margin: const EdgeInsets.only(right: 12),
                        child: LibraryShelfCard(product: product),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),

          // --- Filters ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  ['All', 'Study Material', 'E-Books', 'E-Journals', 'Free']
                      .map(
                        (filter) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ActionChip(
                            label: Text(
                              filter,
                              style: TextStyle(
                                color: appState.homeFilter == filter
                                    ? Colors.white
                                    : theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                            backgroundColor: appState.homeFilter == filter
                                ? theme.colorScheme.primary
                                : theme.cardColor,
                            onPressed: () => appState.applyHomeFilter(filter),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 16),

          // --- Product Listings ---
          Text(
            'Popular Listings',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              // --- MODIFICATION: Changed to 0.75 to make the card taller ---
              childAspectRatio: 0.75,
            ),
            itemCount: productsToDisplay.length,
            itemBuilder: (context, index) {
              return ProductCard(product: productsToDisplay[index]);
            },
          ),

          const SizedBox(height: 32),
          // --- Pagination ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new, size: 16),
                onPressed: appState.homeCurrentPage == 1
                    ? null
                    : () => appState.goToPage(appState.homeCurrentPage - 1),
              ),
              ...List.generate(totalPages, (index) {
                final page = index + 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () => appState.goToPage(page),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appState.homeCurrentPage == page
                          ? theme.colorScheme.primary
                          : theme.cardColor,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(0),
                      minimumSize: const Size(40, 40),
                    ),
                    child: Text(
                      '$page',
                      style: TextStyle(
                        color: appState.homeCurrentPage == page
                            ? Colors.white
                            : theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                );
              }),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: appState.homeCurrentPage == totalPages
                    ? null
                    : () => appState.goToPage(appState.homeCurrentPage + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

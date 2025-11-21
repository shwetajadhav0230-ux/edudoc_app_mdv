import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../data/mock_data.dart'; // REMOVED
import '../../models/product.dart';
import '../../state/app_state.dart';
import '../../widgets/custom_widgets/library_shelf_card.dart';
import '../../widgets/custom_widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _offerPageController;
  late final Timer _offerTimer;
  int _currentOfferPage = 0;

  @override
  void initState() {
    super.initState();
    _offerPageController = PageController(viewportFraction: 0.9);
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
    // Access current offers directly from context safely
    if (!mounted) return;
    final appState = Provider.of<AppState>(context, listen: false);
    final activeOffers = appState.offers.where((o) => o.status == 'Active').toList();

    if (activeOffers.isEmpty) return;

    int nextPage = _currentOfferPage + 1;
    if (nextPage >= activeOffers.length) {
      nextPage = 0;
    }

    if (_offerPageController.hasClients) {
      _offerPageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (!mounted) return;
    final appState = Provider.of<AppState>(context, listen: false);
    final activeOffers = appState.offers.where((o) => o.status == 'Active').toList();

    if (activeOffers.isEmpty) return;

    int prevPage = _currentOfferPage - 1;
    if (prevPage < 0) {
      prevPage = activeOffers.length - 1;
    }
    if (_offerPageController.hasClients) {
      _offerPageController.animateToPage(
        prevPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  // ... [Keep _getCrossAxisCount, _buildOfferCard, _buildArrowButton, _buildPaginationDot helper methods unchanged] ...
  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) return 2;
    else if (screenWidth < 900) return 3;
    else return 4;
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
            gradient: LinearGradient(colors: gradientColors),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildArrowButton(BuildContext context, {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
      child: IconButton(icon: Icon(icon, color: Colors.white, size: 20), onPressed: onPressed),
    );
  }

  Widget _buildPaginationDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8,
      width: isActive ? 16 : 8,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).colorScheme.primary : Colors.blueGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(screenWidth);

    // 1. Get Data from AppState
    final allProducts = appState.products;
    final activeOffers = appState.offers.where((o) => o.status == 'Active').toList();

    // 2. Loading State
    if (appState.isLoadingProducts && allProducts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 3. Filter Products
    final filteredProducts = allProducts.where((p) {
      final currentFilter = appState.homeFilter;
      if (currentFilter == 'All') return true;
      if (currentFilter == 'Free') return p.isFree;
      return p.type.toLowerCase() == currentFilter.toLowerCase();
    }).toList();

    // 4. Pagination Logic
    final startIndex = (appState.homeCurrentPage - 1) * appState.itemsPerPage;
    final endIndex = min(startIndex + appState.itemsPerPage, filteredProducts.length);
    final productsToDisplay = (filteredProducts.isNotEmpty && startIndex < endIndex)
        ? filteredProducts.sublist(startIndex, endIndex)
        : <Product>[];
    final totalPages = (filteredProducts.length / appState.itemsPerPage).ceil();

    // 5. Library Logic
    final List<Product> ownedProductsForShelf = appState.ownedProductIds.expand((id) {
      try {
        final product = allProducts.firstWhere((p) => p.id == id);
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
          Text('Discover Premium Docs', style: theme.textTheme.titleLarge?.copyWith(fontSize: 24, color: theme.colorScheme.primary)),
          const SizedBox(height: 16),

          // --- Carousel (Use activeOffers) ---
          if (activeOffers.isNotEmpty)
            Column(
              children: [
                SizedBox(
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PageView.builder(
                        controller: _offerPageController,
                        onPageChanged: (index) => setState(() => _currentOfferPage = index),
                        itemCount: activeOffers.length,
                        itemBuilder: (context, index) {
                          final offer = activeOffers[index];
                          return _buildOfferCard(
                            context: context,
                            appState: appState,
                            theme: theme,
                            title: "${offer.discount} OFF\n${offer.title}",
                            gradientColors: index % 2 == 0
                                ? [theme.colorScheme.primary, theme.colorScheme.secondary]
                                : [Colors.teal.shade400, theme.colorScheme.primary],
                            onTap: () => appState.navigate(AppScreen.offerDetails, id: offer.id.toString()),
                          );
                        },
                      ),
                      Positioned(left: 0, child: _buildArrowButton(context, icon: Icons.arrow_back_ios_new, onPressed: _prevPage)),
                      Positioned(right: 0, child: _buildArrowButton(context, icon: Icons.arrow_forward_ios, onPressed: _nextPage)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(activeOffers.length, (index) {
                    return _buildPaginationDot(isActive: index == _currentOfferPage);
                  }),
                ),
              ],
            ),
          const SizedBox(height: 16),

          // ... [Keep Library Shelf, Filters, Product Grid, and Pagination UI unchanged] ...
          // (Just ensure you use 'productsToDisplay', 'ownedProductsForShelf', etc calculated above)

          if (ownedProductsForShelf.isNotEmpty) ...[
            Text('My Library', style: theme.textTheme.titleLarge?.copyWith(fontSize: 20)),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ListView.builder(
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
          ],

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Study Material', 'E-Books', 'E-Journals', 'Free'].map(
                    (filter) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text(filter, style: TextStyle(color: appState.homeFilter == filter ? Colors.white : theme.textTheme.bodyMedium?.color)),
                    backgroundColor: appState.homeFilter == filter ? theme.colorScheme.primary : theme.cardColor,
                    onPressed: () => appState.applyHomeFilter(filter),
                  ),
                ),
              ).toList(),
            ),
          ),
          const SizedBox(height: 16),

          Text('Popular Listings', style: theme.textTheme.titleLarge?.copyWith(fontSize: 20)),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.75,
            ),
            itemCount: productsToDisplay.length,
            itemBuilder: (context, index) => ProductCard(product: productsToDisplay[index]),
          ),

          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                onPressed: appState.homeCurrentPage == 1 ? null : () => appState.goToPage(appState.homeCurrentPage - 1),
              ),
              ...List.generate(totalPages, (index) {
                final page = index + 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () => appState.goToPage(page),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appState.homeCurrentPage == page ? theme.colorScheme.primary : theme.cardColor,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(0),
                      minimumSize: const Size(40, 40),
                    ),
                    child: Text('$page', style: TextStyle(color: appState.homeCurrentPage == page ? Colors.white : theme.textTheme.bodyMedium?.color)),
                  ),
                );
              }),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: appState.homeCurrentPage == totalPages ? null : () => appState.goToPage(appState.homeCurrentPage + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
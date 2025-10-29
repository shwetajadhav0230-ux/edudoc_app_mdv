// Auto-generated AppState

import 'package:flutter/material.dart';

import '../models/product.dart';
// NOTE: Assuming external data dependencies (dummyProducts, etc.) are available

enum AppScreen {
  welcome,
  login,
  signup,
  permissions,
  lockUnlock,
  home,
  search,
  productDetails,
  cart,
  wallet,
  profile,
  settings,
  bookmarks,
  library,
  offers,
  offerDetails,
  userActivity,
  adminDashboard,
  reading,
}

class AppState extends ChangeNotifier {
  // --- Global State ---
  AppScreen _currentScreen = AppScreen.home;
  AppScreen _previousPage = AppScreen.home;
  String _userRole = 'Admin';
  bool _isDarkTheme = true;
  String? _selectedProductId;
  String? _selectedOfferId;

  // --- User/Wallet State ---
  int _walletTokens = 450;
  // Note: Initial cart is set to empty to avoid dependency errors here.
  final List<Product> _cartItems = [];

  final List<int> _bookmarkedProductIds = [1, 6];
  final Map<String, dynamic> _currentUser = {
    'name': 'Jane Doe',
    'email': 'jane.doe@edudoc.com',
  };
  Map<String, dynamic> get currentUser => _currentUser;
  String _pinCode = '';
  final String correctPin = '1234';
  bool _showPasswordUnlock = false;

  // --- Home/Search State ---
  String _homeFilter = 'all';
  int _homeCurrentPage = 1;
  final int itemsPerPage = 6;

  // --- Data Accessors ---
  AppScreen get currentScreen => _currentScreen;
  String get userRole => _userRole;
  bool get isDarkTheme => _isDarkTheme;
  int get walletTokens => _walletTokens;
  List<Product> get cartItems => _cartItems;
  List<int> get bookmarkedProductIds => _bookmarkedProductIds;
  String get pinCode => _pinCode;
  bool get showPasswordUnlock => _showPasswordUnlock;
  String? get selectedProductId => _selectedProductId;
  String? get selectedOfferId => _selectedOfferId;
  String get homeFilter => _homeFilter;
  int get homeCurrentPage => _homeCurrentPage;

  // --- Navigation & Routing ---
  void navigate(AppScreen screen, {String? id}) {
    if (_currentScreen != AppScreen.reading &&
        _currentScreen != AppScreen.lockUnlock) {
      _previousPage = _currentScreen;
    }
    _currentScreen = screen;
    _selectedProductId = (screen == AppScreen.productDetails) ? id : null;
    _selectedOfferId = (screen == AppScreen.offerDetails) ? id : null;
    notifyListeners();
  }

  void navigateBack() {
    if (_currentScreen == AppScreen.reading) {
      navigate(_previousPage);
    } else if (_currentScreen == AppScreen.productDetails ||
        _currentScreen == AppScreen.offerDetails) {
      navigate(_previousPage);
    } else {
      navigate(AppScreen.home);
    }
  }

  // --- Theme/Role Logic ---
  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }

  void toggleUserRole() {
    _userRole = _userRole == 'Admin' ? 'User' : 'Admin';
    if (_currentScreen == AppScreen.adminDashboard ||
        _currentScreen == AppScreen.userActivity) {
      navigate(AppScreen.home);
    }
    notifyListeners();
  }

  // --- Auth Lock Logic ---
  void pinEnter(String digit) {
    if (_pinCode.length < 4) {
      _pinCode += digit;
      notifyListeners();

      if (_pinCode.length == 4) {
        if (_pinCode == correctPin) {
          Future.delayed(const Duration(milliseconds: 500), () {
            navigate(AppScreen.home);
            _pinCode = '';
          });
        } else {
          Future.delayed(const Duration(seconds: 1), () {
            _pinCode = '';
            notifyListeners();
          });
        }
      }
    }
  }

  void pinClear() {
    if (_pinCode.isNotEmpty) {
      _pinCode = _pinCode.substring(0, _pinCode.length - 1);
    }
    notifyListeners();
  }

  void togglePinView(bool showPassword) {
    _showPasswordUnlock = showPassword;
    _pinCode = '';
    notifyListeners();
  }

  // --- Cart/Wallet/Bookmark Logic ---
  void addToCart(Product product) {
    if (product.isFree) return;
    if (_cartItems.any((item) => item.id == product.id)) return;
    _cartItems.add(product);
    notifyListeners();
  }

  // INTEGRATED FIX: Method to add the Annual Pro Pack
  void addProPackToCart() {
    // Define a mock 'Product' representing the subscription/pack (ID 999, Price 300)
    final proPack = Product(
      id: 999,
      type: 'Subscription',
      title: 'Annual Pro Pack',
      description: 'Unlimited access for one year.',
      price: 300,
      isFree: false,
      category: 'Premium',
      tags: ['Unlimited'],
      rating: 5.0,
      author: 'EduDoc',
      pages: 0,
      reviewCount: 0,
      details: 'The ultimate subscription for full library access.',
      content: 'N/A',
      imageUrl: '', // Non-nullable field handled
    );

    // Check if Pro Pack is already in cart to prevent duplicates
    if (!_cartItems.any((item) => item.id == proPack.id)) {
      _cartItems.add(proPack);
      notifyListeners();
    }
  }

  void removeCartItem(int id) {
    _cartItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void buyTokens(int amount) {
    _walletTokens += amount;
    notifyListeners();
  }

  void checkout() {
    final totalCost = _cartItems.fold(0, (sum, item) => sum + item.price);
    if (totalCost > _walletTokens) return;

    _walletTokens -= totalCost;
    for (var item in _cartItems) {
      if (!_bookmarkedProductIds.contains(item.id)) {
        _bookmarkedProductIds.add(item.id);
      }
    }
    _cartItems.clear();
    notifyListeners();
  }

  void toggleBookmark(int id) {
    if (_bookmarkedProductIds.contains(id)) {
      _bookmarkedProductIds.remove(id);
    } else {
      _bookmarkedProductIds.add(id);
    }
    notifyListeners();
  }

  // --- Home/Pagination Logic ---
  void applyHomeFilter(String filter) {
    _homeFilter = filter;
    _homeCurrentPage = 1;
    notifyListeners();
  }

  void goToPage(int page) {
    _homeCurrentPage = page;
    notifyListeners();
  }
}

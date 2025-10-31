// Auto-generated AppState

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/user.dart'; // Import the new User model
// Note: Assuming Offer model is available in the scope of AppState

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
  // NEW: Profile Edit Screen
  profileEdit,
}

class AppState extends ChangeNotifier {
  // --- Global State ---
  // FIX APPLIED: Initial screen set to 'home' for stability
  AppScreen _currentScreen = AppScreen.home;
  AppScreen _previousPage = AppScreen.home;
  String _userRole = 'Admin';
  bool _isDarkTheme = true;
  String? _selectedProductId;
  String? _selectedOfferId;

  // --- User/Profile State ---
  int _walletTokens = 450;
  final List<Product> _cartItems = [];
  final List<int> _bookmarkedProductIds = [1, 6];

  // FIX: User object used for profile management
  User _currentUser = User(
    id: 'user_123',
    fullName: 'Jane Doe',
    email: 'jane.doe@edudoc.com',
    phoneNumber: '555-1234',
    bio: 'Avid student and note taker.',
    profileImageBase64: null, // Starts null
  );

  // --- Profile Image Handling State ---
  bool _isImageProcessing = false;

  // --- FIX: Auth/Lock Screen State ---
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
  User get currentUser => _currentUser;
  bool get isImageProcessing => _isImageProcessing;
  String get homeFilter => _homeFilter;
  int get homeCurrentPage => _homeCurrentPage;

  // FIX: Auth/Lock Screen Getters
  String get pinCode => _pinCode;
  bool get showPasswordUnlock => _showPasswordUnlock;
  String? get selectedProductId => _selectedProductId;
  String? get selectedOfferId => _selectedOfferId;

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
    } else if (_currentScreen == AppScreen.profileEdit) {
      navigate(AppScreen.profile); // Explicitly go back to profile view
    } else {
      navigate(AppScreen.home);
    }
  }

  // --- Image Processing Flag ---
  void setImageProcessing(bool processing) {
    _isImageProcessing = processing;
    notifyListeners();
  }

  // --- Profile Management ---
  void saveProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String bio,
    String? profileImageBase64,
  }) {
    // Update the local User object state
    _currentUser = _currentUser.copyWith(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      bio: bio,
      profileImageBase64: profileImageBase64,
    );
    notifyListeners();

    // Navigate back to the main profile page
    navigate(AppScreen.profile);
  }

  // FIX: Auth Lock Logic Methods
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

  // --- Cart/Wallet/Bookmark Logic ---
  void addToCart(Product product) {
    if (product.isFree) return;
    if (_cartItems.any((item) => item.id == product.id)) return;
    _cartItems.add(product);
    notifyListeners();
  }

  // INTEGRATED FIX: Method to add the Annual Pro Pack
  void addProPackToCart() {
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
      imageUrl: '',
    );
    if (!_cartItems.any((item) => item.id == proPack.id)) {
      _cartItems.add(proPack);
      notifyListeners();
    }
  }

  // NEW METHOD: Adds all products in a specific bundle (Offer) to the cart.
  void addBundleToCart(dynamic offer) {
    if (offer.status != 'Active') return;

    // Remove any mock bundle/pack items first to ensure a clean addition
    _cartItems.removeWhere((item) => item.id == 999 || item.id == offer.id);

    // Create a mock product representing the bundle itself for the cart/summary view
    final bundleProduct = Product(
      id: offer.id,
      type: 'Bundle',
      title: offer.title,
      description: 'Bundle discount: ${offer.discount}',
      price: offer.tokenPrice,
      isFree: offer.tokenPrice == 0,
      category: 'Bundle',
      tags: [],
      rating: 0.0,
      author: 'System',
      pages: offer.productIds.length,
      reviewCount: 0,
      details: 'Includes ${offer.productIds.length} documents.',
      content: 'N/A',
      imageUrl: '',
    );

    // Check if the bundle itself is already in the cart
    if (!_cartItems.any((item) => item.id == bundleProduct.id)) {
      _cartItems.add(bundleProduct);
      notifyListeners();
    }
  }

  void removeCartItem(int id) {
    _cartItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void buyTokens(int amount) {
    _walletTokens += amount;
    // Assuming transactionHistory handling is done via side effect
    notifyListeners();
  }

  void checkout() {
    final totalCost = _cartItems.fold(0, (sum, item) => sum + item.price);
    if (totalCost > _walletTokens) return;

    _walletTokens -= totalCost;
    for (var item in _cartItems) {
      // Assuming transactionHistory handling is done via side effect
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

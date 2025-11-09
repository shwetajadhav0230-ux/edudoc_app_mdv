// lib/state/app_state.dart

import 'package:flutter/material.dart';

import '../data/mock_data.dart' as mock_data;
import '../models/product.dart';
import '../models/transaction.dart';
import '../models/user.dart';

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
  // --- NEW SETTINGS DESTINATIONS ---
  emailManagement, // Added for Email Address settings
  changePassword, // Added for Change Password settings
  about, // Added for About EduDoc
  helpSupport, // Added for Help & Support
}

class AppState extends ChangeNotifier {
  // --- Global State ---
  AppScreen _currentScreen = AppScreen.welcome;
  AppScreen _previousPage = AppScreen.home;
  String _userRole = 'user';
  bool _isDarkTheme = true;
  String? _selectedProductId;
  String? _selectedOfferId;

  // --- Settings State Variables ---
  bool _isBiometricEnabled = false; // Initialize to false
  bool _areNotificationsEnabled = true; // Initialize to true
  bool _isPromoEmailEnabled = false; // Initialize to false

  // --- NEW: Reader Settings State (For Settings Dialog Functionality) ---
  String _readerPageFlipping = 'Horizontal';
  String _readerColorMode = 'Day';
  double _readerFontSize = 42;
  double _readerLineSpacing = 100;
  // NEW: Helper property to track if reader settings have changed
  int _readerSettingsVersion = 0;

  // --- Transaction History State ---
  final List<Transaction> _transactionHistory =
      mock_data.transactionHistory.toList();

  // --- User/Profile State ---
  int _walletTokens = 450;
  final List<Product> _cartItems = [];
  final List<int> _bookmarkedProductIds = [1, 6];
  final List<int> _ownedProductIds = [101, 102]; // Library/Purchased items

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
  List<int> get ownedProductIds => _ownedProductIds; // Added for Library
  User get currentUser => _currentUser;
  bool get isImageProcessing => _isImageProcessing;
  String get homeFilter => _homeFilter;
  int get homeCurrentPage => _homeCurrentPage;

  // --- ADDED: GETTER FOR THE TRANSACTION LIST ---
  List<Transaction> get transactionHistory => _transactionHistory;

  // --- Settings Getters ---
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get areNotificationsEnabled => _areNotificationsEnabled;
  bool get isPromoEmailEnabled => _isPromoEmailEnabled;

  // --- CRITICAL: Reader Settings Getters (Used to initialize Dialog State) ---
  String get readerPageFlipping => _readerPageFlipping;
  String get readerColorMode => _readerColorMode;
  double get readerFontSize => _readerFontSize;
  double get readerLineSpacing => _readerLineSpacing;
  // NEW: Getter for version number
  int get readerSettingsVersion => _readerSettingsVersion;

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
    _selectedProductId =
        (screen == AppScreen.productDetails || screen == AppScreen.reading)
            ? id
            : null;
    _selectedOfferId = (screen == AppScreen.offerDetails) ? id : null;
    notifyListeners();
  }

  void navigateBack() {
    // 1. Deep Settings Screens: always go back to AppScreen.settings
    if (_currentScreen == AppScreen.emailManagement ||
        _currentScreen == AppScreen.changePassword ||
        _currentScreen == AppScreen.about ||
        _currentScreen == AppScreen.helpSupport) {
      navigate(AppScreen.settings);
      return;
    }

    // 2. Secondary Screens (opened from home/profile) that go back to previous page
    if (_currentScreen == AppScreen.reading ||
        _currentScreen == AppScreen.productDetails ||
        _currentScreen == AppScreen.offerDetails ||
        _currentScreen == AppScreen.userActivity ||
        _currentScreen == AppScreen.wallet ||
        _currentScreen == AppScreen.search) {
      navigate(_previousPage);
      return;
    }

    // 3. Top-level screens/tabs that go back to Home
    if (_currentScreen == AppScreen.settings ||
        _currentScreen == AppScreen.profileEdit ||
        _currentScreen == AppScreen.library ||
        _currentScreen == AppScreen.cart ||
        _currentScreen == AppScreen.profile ||
        _currentScreen == AppScreen.bookmarks ||
        _currentScreen == AppScreen.offers) {
      navigate(AppScreen.home);
      return;
    }

    // 4. Default fallback (e.g., from Home, Welcome, Auth Screens)
    navigate(AppScreen.home);
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

  // --- Settings Toggles Implementation ---

  /// Toggles the state of biometric login (Fingerprint/Face ID).
  void toggleBiometrics(bool newValue) {
    _isBiometricEnabled = newValue;
    notifyListeners();
  }

  /// Toggles all main application notifications.
  void toggleAppNotifications(bool newValue) {
    _areNotificationsEnabled = newValue;
    notifyListeners();
  }

  /// Toggles promotional email subscription status.
  void togglePromoEmails(bool newValue) {
    _isPromoEmailEnabled = newValue;
    notifyListeners();
  }

  // --- CRITICAL: Reader Settings Mutators (Used by ReaderSettingsDialog) ---

  // Helper to increment version number when any reader setting changes
  void _incrementReaderVersion() {
    _readerSettingsVersion++;
  }

  /// Updates the page flipping mode (Horizontal/Vertical).
  void setReaderPageFlipping(String mode) {
    _readerPageFlipping = mode;
    _incrementReaderVersion(); // Signal change
    notifyListeners();
  }

  /// Updates the reading color mode (Day/Night/Sepia).
  void setReaderColorMode(String mode) {
    _readerColorMode = mode;
    _incrementReaderVersion(); // Signal change
    notifyListeners();
  }

  /// Updates the reader font size.
  void setReaderFontSize(double size) {
    _readerFontSize = size;
    _incrementReaderVersion(); // Signal change
    notifyListeners();
  }

  /// Updates the reader line spacing.
  void setReaderLineSpacing(double spacing) {
    _readerLineSpacing = spacing;
    _incrementReaderVersion(); // Signal change
    notifyListeners();
  }

  // --- Cart/Wallet/Bookmark Logic ---
  void addToCart(Product product) {
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

    // Create a new transaction object
    final newTx = Transaction(
      id: DateTime.now().millisecondsSinceEpoch, // Unique ID
      type: 'Credit',
      amount: amount,
      date: 'Nov 4, 2025', // Using a mock date
      description: 'Package purchase',
    );

    // Add it to the list (at the top)
    _transactionHistory.insert(0, newTx);

    notifyListeners();
  }

  // FIX: Checkout now adds purchased items to the *Library* list (`_ownedProductIds`)
  void checkout() {
    final totalCost = _cartItems.fold(0, (sum, item) => sum + item.price);
    // MODIFIED: Check if cart is empty after checking cost
    if (totalCost > _walletTokens || _cartItems.isEmpty) return;

    _walletTokens -= totalCost;

    for (var item in _cartItems) {
      // Logic: Only add purchased products to the library (ownedProductIds)
      // (Don't add subscriptions/bundles to the library)
      if (!item.isFree &&
          item.type != 'Subscription' &&
          item.type != 'Bundle' &&
          !_ownedProductIds.contains(item.id)) {
        _ownedProductIds.add(item.id);
      }

      // Create a transaction for this purchase/download
      final newTx = Transaction(
        id: DateTime.now().millisecondsSinceEpoch + item.id, // Unique ID
        type: item.isFree ? 'Download' : 'Debit',
        amount: item.price,
        date: 'Nov 4, 2025', // Using a mock date
        description: item.isFree
            ? 'Downloaded ${item.title}'
            : 'Purchased ${item.title}',
      );

      // Add it to the list (at the top)
      _transactionHistory.insert(0, newTx);
    }

    _cartItems.clear();
    notifyListeners();
  }

  // Original functionality remains for Wishlist
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

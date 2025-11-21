import 'dart:convert'; // Required for JSON serialization
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Required for Local Storage
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/data_service.dart';
// import '../data/mock_data.dart' as mock_data; // REMOVED: Mock data no longer needed
import '../models/product.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../models/offer.dart'; // Ensure this is imported

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
  profileEdit,
  emailManagement,
  changePassword,
  about,
  helpSupport,
}

class AppState extends ChangeNotifier {
  // --- Global State ---
  AppScreen _currentScreen = AppScreen.welcome;
  final List<AppScreen> _historyStack = [];
  final DataService _dataService = DataService();

  // --- Data Lists (Fetched from Supabase) ---
  List<Product> _products = [];
  List<Offer> _offers = [];

  bool _isLoadingProducts = false;
  bool _isLoadingOffers = false;

  // --- User/Profile State (Locally Persisted) ---
  int _walletTokens = 450; // Default value, will be overwritten by local storage
  List<Transaction> _transactionHistory = [];
  List<int> _ownedProductIds = [101, 102]; // Default starter items
  final List<int> _bookmarkedProductIds = [];
  final List<Product> _cartItems = [];

  String _userRole = 'user';
  bool _isDarkTheme = true;
  String? _selectedProductId;
  String? _selectedOfferId;

  // --- Settings State Variables ---
  bool _isBiometricEnabled = false;
  bool _areNotificationsEnabled = true;
  bool _isPromoEmailEnabled = false;

  // --- Reader Settings State ---
  String _readerPageFlipping = 'Horizontal';
  String _readerColorMode = 'Day';
  double _readerFontSize = 42;
  double _readerLineSpacing = 100;
  int _readerSettingsVersion = 0;

  // --- User Profile Object ---
  User _currentUser = User(
    id: 'user_123',
    fullName: 'Jane Doe',
    email: 'jane.doe@edudoc.com',
    phoneNumber: '555-1234',
    bio: 'Avid student and note taker.',
    profileImageBase64: null,
  );

  bool _isImageProcessing = false;

  // --- Auth/Lock Screen State ---
  String _pinCode = '';
  final String correctPin = '1234';
  bool _showPasswordUnlock = false;

  // --- Home/Search State ---
  String _homeFilter = 'All';
  int _homeCurrentPage = 1;
  final int itemsPerPage = 6;

  // --- Getters ---
  AppScreen get currentScreen => _currentScreen;
  String get userRole => _userRole;
  bool get isDarkTheme => _isDarkTheme;
  int get walletTokens => _walletTokens;

  List<Product> get products => _products;
  List<Offer> get offers => _offers;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isLoadingOffers => _isLoadingOffers;

  List<Product> get cartItems => _cartItems;
  List<int> get bookmarkedProductIds => _bookmarkedProductIds;
  List<int> get ownedProductIds => _ownedProductIds;
  User get currentUser => _currentUser;
  bool get isImageProcessing => _isImageProcessing;
  String get homeFilter => _homeFilter;
  int get homeCurrentPage => _homeCurrentPage;
  List<Transaction> get transactionHistory => _transactionHistory;

  // Settings Getters
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get areNotificationsEnabled => _areNotificationsEnabled;
  bool get isPromoEmailEnabled => _isPromoEmailEnabled;

  // Reader Getters
  String get readerPageFlipping => _readerPageFlipping;
  String get readerColorMode => _readerColorMode;
  double get readerFontSize => _readerFontSize;
  double get readerLineSpacing => _readerLineSpacing;
  int get readerSettingsVersion => _readerSettingsVersion;

  // Auth Getters
  String get pinCode => _pinCode;
  bool get showPasswordUnlock => _showPasswordUnlock;
  String? get selectedProductId => _selectedProductId;
  String? get selectedOfferId => _selectedOfferId;

  // --- Constructor & Initialization ---
  AppState() {
    _initApp();
  }

  Future<void> _initApp() async {
    // 1. Load Local Data (Wallet, History, Library)
    await _loadLocalData();

    // 2. Fetch Cloud Data (Products, Offers)
    fetchProducts();
    fetchOffers();
  }

  // --- Data Fetching (Supabase) ---

  Future<void> fetchProducts() async {
    _isLoadingProducts = true;
    notifyListeners();

    try {
      final fetchedProducts = await _dataService.getProducts();
      if (fetchedProducts.isNotEmpty) {
        _products = fetchedProducts;
      }
    } catch (e) {
      debugPrint("Error fetching products: $e");
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> fetchOffers() async {
    _isLoadingOffers = true;
    notifyListeners();

    try {
      // Ensure your DataService has a getOffers() method implemented
      final fetchedOffers = await _dataService.getOffers();
      if (fetchedOffers.isNotEmpty) {
        _offers = fetchedOffers;
      }
    } catch (e) {
      debugPrint("Error fetching offers: $e");
    } finally {
      _isLoadingOffers = false;
      notifyListeners();
    }
  }

  // --- Local Storage Logic (Persistence) ---

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Load Transaction History
    final String? historyJson = prefs.getString('transaction_history');
    if (historyJson != null) {
      try {
        final List<dynamic> decodedList = json.decode(historyJson);
        _transactionHistory = decodedList
            .map((item) => Transaction.fromMap(item))
            .toList();
      } catch (e) {
        debugPrint('Error parsing transaction history: $e');
      }
    }

    // 2. Load Owned Products (Library)
    final List<String>? ownedList = prefs.getStringList('owned_products');
    if (ownedList != null) {
      _ownedProductIds = ownedList.map((e) => int.tryParse(e) ?? 0).toList();
    }

    // 3. Load Wallet Balance
    _walletTokens = prefs.getInt('wallet_tokens') ?? 450;

    notifyListeners();
  }

  Future<void> _saveLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Save Transaction History
    // Ensure Transaction model has toMap() implemented
    final String historyJson = json.encode(
      _transactionHistory.map((tx) => tx.toMap()).toList(),
    );
    await prefs.setString('transaction_history', historyJson);

    // 2. Save Owned Products
    final List<String> ownedList =
    _ownedProductIds.map((id) => id.toString()).toList();
    await prefs.setStringList('owned_products', ownedList);

    // 3. Save Wallet Balance
    await prefs.setInt('wallet_tokens', _walletTokens);
  }

  // --- Navigation & Routing ---
  void navigate(AppScreen screen, {String? id}) {
    final List<AppScreen> rootScreens = [
      AppScreen.home,
      AppScreen.library,
      AppScreen.cart,
      AppScreen.profile,
      AppScreen.settings,
      AppScreen.offers,
    ];

    if (rootScreens.contains(screen)) {
      _historyStack.clear();
    } else if (_currentScreen != screen && _currentScreen != AppScreen.welcome) {
      _historyStack.add(_currentScreen);
    }

    _currentScreen = screen;
    _selectedProductId = (screen == AppScreen.productDetails || screen == AppScreen.reading) ? id : null;
    _selectedOfferId = (screen == AppScreen.offerDetails) ? id : null;

    notifyListeners();
  }

  void navigateBack() {
    if (_historyStack.isEmpty) {
      _currentScreen = AppScreen.home;
      notifyListeners();
      return;
    }

    final previousScreen = _historyStack.removeLast();
    _currentScreen = previousScreen;
    _selectedProductId = null;
    _selectedOfferId = null;

    notifyListeners();
  }

  // --- Profile & Auth Logic ---
  void setImageProcessing(bool processing) {
    _isImageProcessing = processing;
    notifyListeners();
  }

  void saveProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String bio,
    String? profileImageBase64,
  }) {
    _currentUser = _currentUser.copyWith(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      bio: bio,
      profileImageBase64: profileImageBase64,
    );
    notifyListeners();
    navigate(AppScreen.profile);
  }

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

  // --- Settings Toggles ---
  void toggleBiometrics(bool newValue) {
    _isBiometricEnabled = newValue;
    notifyListeners();
  }

  void toggleAppNotifications(bool newValue) {
    _areNotificationsEnabled = newValue;
    notifyListeners();
  }

  void togglePromoEmails(bool newValue) {
    _isPromoEmailEnabled = newValue;
    notifyListeners();
  }

  // --- Reader Settings ---
  void _incrementReaderVersion() {
    _readerSettingsVersion++;
  }

  void setReaderPageFlipping(String mode) {
    _readerPageFlipping = mode;
    _incrementReaderVersion();
    notifyListeners();
  }

  void setReaderColorMode(String mode) {
    _readerColorMode = mode;
    _incrementReaderVersion();
    notifyListeners();
  }

  void setReaderFontSize(double size) {
    _readerFontSize = size;
    _incrementReaderVersion();
    notifyListeners();
  }

  void setReaderLineSpacing(double spacing) {
    _readerLineSpacing = spacing;
    _incrementReaderVersion();
    notifyListeners();
  }

  // --- Cart, Wallet & Transaction Logic ---

  void addToCart(Product product) {
    if (_cartItems.any((item) => item.id == product.id)) return;
    _cartItems.add(product);
    notifyListeners();
  }

  /// Adds a free product directly to the library and persists the transaction
  void addToLibrary(Product product) {
    if (!_ownedProductIds.contains(product.id)) {
      _ownedProductIds.add(product.id);

      final newTx = Transaction(
        id: DateTime.now().millisecondsSinceEpoch + product.id,
        type: 'Download',
        amount: 0,
        date: DateTime.now().toString().split(' ')[0],
        description: 'Downloaded ${product.title}',
      );

      _transactionHistory.insert(0, newTx);
      _saveLocalData(); // SAVE TO DISK
      notifyListeners();
    }
  }

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

  void addBundleToCart(Offer offer) {
    if (offer.status != 'Active') return;

    _cartItems.removeWhere((item) => item.id == 999 || item.id == offer.id);

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
      // Store productIds list as a string in content field for checkout parsing
      content: offer.productIds.map((id) => id.toString()).join(','),
      imageUrl: '',
    );

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

    final newTx = Transaction(
      id: DateTime.now().millisecondsSinceEpoch,
      type: 'Credit',
      amount: amount,
      date: DateTime.now().toString().split(' ')[0],
      description: 'Package purchase',
    );

    _transactionHistory.insert(0, newTx);
    _saveLocalData(); // SAVE TO DISK
    notifyListeners();
  }

  void checkout() {
    final totalCost = _cartItems.fold(0, (sum, item) => sum + item.price);
    if (totalCost > _walletTokens || _cartItems.isEmpty) return;

    if (totalCost > 0) {
      _walletTokens -= totalCost;
    }

    final List<int> productsToAddToLibrary = [];

    for (var item in _cartItems) {
      // Case 1: Single Document
      if (item.type != 'Subscription' && item.type != 'Bundle') {
        productsToAddToLibrary.add(item.id);
      }

      // Case 2: Bundle (Parse stored IDs from content string)
      if (item.type == 'Bundle' && item.content.isNotEmpty) {
        try {
          final List<int> bundledIds = item.content
              .split(',')
              .map((idStr) => int.tryParse(idStr))
              .whereType<int>()
              .toList();
          productsToAddToLibrary.addAll(bundledIds);
        } catch (e) {
          debugPrint('Error parsing bundle IDs: $e');
        }
      }

      // Record Transaction
      final newTx = Transaction(
        id: DateTime.now().millisecondsSinceEpoch + item.id,
        type: item.isFree ? 'Download' : 'Debit',
        amount: item.price,
        date: DateTime.now().toString().split(' ')[0],
        description: item.isFree
            ? 'Downloaded ${item.title}'
            : 'Purchased ${item.title}',
      );
      _transactionHistory.insert(0, newTx);
    }

    // Add to owned library
    for (int id in productsToAddToLibrary) {
      if (!_ownedProductIds.contains(id)) {
        _ownedProductIds.add(id);
      }
    }

    _cartItems.clear();
    _saveLocalData(); // SAVE TO DISK
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
// lib/state/app_state.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:local_auth/local_auth.dart';
import 'package:image_picker/image_picker.dart';

// Services
import '../services/data_service.dart';
import '../services/auth_service.dart';
import '../services/file_service.dart';
import '../services/notification_service.dart';

// Models
import '../models/product.dart';
import '../models/transaction.dart';
import '../models/user.dart';
import '../models/offer.dart';

// ---------------------------------------------------------------------------
// APP SCREEN ENUM
// ---------------------------------------------------------------------------
enum AppScreen {
  splash, welcome, login, signup, verifyEmail, permissions, lockUnlock,
  home, search, productDetails, cart, wallet, profile, settings,
  bookmarks, library, offers, offerDetails, userActivity, adminDashboard,
  reading, profileEdit, profileSetup, emailManagement, changePassword,
  about, helpSupport,
}

// ---------------------------------------------------------------------------
// APP STATE CLASS
// ---------------------------------------------------------------------------
class AppState extends ChangeNotifier {
  String? _transactionPin;
  bool get isTransactionPinSet => _transactionPin != null && _transactionPin!.isNotEmpty;
  bool _isPinSet = false;
  bool get isPinSet => _isPinSet;

  // --- Services ---
  final DataService _dataService = DataService();
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  final FileService _fileService = FileService();

  // --- Global State ---
  AppScreen _currentScreen = AppScreen.splash;
  final List<AppScreen> _historyStack = [];

  // Subscription
  StreamSubscription<List<Map<String, dynamic>>>? _walletSubscription;
  late final StreamSubscription<supabase.AuthState> _authSubscription;

  DateTime? _lastPausedTime;
  int _autoLockSeconds = 300;

  // --- Data Lists ---
  List<Product> _products = [];
  List<Offer> _offers = [];
  String _selectedCategory = 'All';

  bool _isLoadingProducts = false;
  bool _isLoadingOffers = false;

  // --- User/Profile State ---
  int _walletTokens = 0;
  List<Transaction> _transactionHistory = [];
  List<int> _ownedProductIds = [];
  final List<int> _bookmarkedProductIds = [];
  final List<Product> _cartItems = [];

  String _userRole = 'user';
  bool _isDarkTheme = true;
  String? _selectedProductId;
  String? _selectedOfferId;

  // --- Settings State ---
  bool _isBiometricEnabled = false;
  bool _areNotificationsEnabled = true;
  bool _isPromoEmailEnabled = false;
  bool _hasSkippedSetup = false;

  // --- Reader Settings ---
  String _readerPageFlipping = 'Horizontal';
  String _readerColorMode = 'Day';
  double _readerFontSize = 42;
  double _readerLineSpacing = 100;
  int _readerSettingsVersion = 0;

  // --- User Profile Object ---
  User _currentUser = User(
    id: '', fullName: '', email: '', phoneNumber: '', profileImageUrl: null,
  );

  bool _isImageProcessing = false;

  // --- Auth/Lock Screen State ---
  String _pinCode = '';
  // ✅ RESTORED: Needed by LockScreen
  final String correctPin = '1234';
  bool _showPasswordUnlock = false;
  String? _pendingEmail;

  // --- Home/Pagination State ---
  String _homeFilter = 'All';
  int _homeCurrentPage = 1;
  final int itemsPerPage = 6;
  List<String> _searchHistory = [];
  Map<String, double> _downloadProgress = {};

  // -------------------------------------------------------------------------
  // GETTERS
  // -------------------------------------------------------------------------
  AppScreen get currentScreen => _currentScreen;
  String get userRole => _userRole;
  bool get isDarkTheme => _isDarkTheme;
  int get walletTokens => _walletTokens;
  bool get isProfileIncomplete => _currentUser.phoneNumber.isEmpty;
  int get autoLockSeconds => _autoLockSeconds;
  String get selectedCategory => _selectedCategory;

  // ✅ RESTORED: Needed by SettingsScreen
  Future<List<BiometricType>> get enrolledBiometrics => _authService.getAvailableBiometrics();

  bool get isBiometricEnabled => _isBiometricEnabled;
  List<Product> get products => _products;
  List<Offer> get offers => _offers;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isLoadingOffers => _isLoadingOffers;
  List<String> get searchHistory => _searchHistory;
  List<Product> get cartItems => _cartItems;
  List<int> get bookmarkedProductIds => _bookmarkedProductIds;
  List<int> get ownedProductIds => _ownedProductIds;
  User get currentUser => _currentUser;
  bool get isImageProcessing => _isImageProcessing;
  String get homeFilter => _homeFilter;
  int get homeCurrentPage => _homeCurrentPage;
  List<Transaction> get transactionHistory => _transactionHistory;
  Map<String, double> get downloadProgress => _downloadProgress;
  bool get areNotificationsEnabled => _areNotificationsEnabled;
  bool get isPromoEmailEnabled => _isPromoEmailEnabled;

  String get readerPageFlipping => _readerPageFlipping;
  String get readerColorMode => _readerColorMode;
  double get readerFontSize => _readerFontSize;
  double get readerLineSpacing => _readerLineSpacing;
  int get readerSettingsVersion => _readerSettingsVersion;

  String get pinCode => _pinCode;
  bool get showPasswordUnlock => _showPasswordUnlock;
  String? get selectedProductId => _selectedProductId;
  String? get selectedOfferId => _selectedOfferId;

  List<Product> get filteredProducts {
    if (_selectedCategory == 'All') {
      return _products;
    }
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  List<Product> get topRatedProducts {
    List<Product> sorted = List.from(_products);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(6).toList();
  }

  List<Product> get newArrivals {
    List<Product> sorted = List.from(_products);
    sorted.sort((a, b) => b.id.compareTo(a.id));
    return sorted.take(6).toList();
  }

  // -------------------------------------------------------------------------
  // CONSTRUCTOR & INITIALIZATION
  // -------------------------------------------------------------------------
  AppState() {
    _initApp();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _walletSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initApp() async {
    await _notificationService.init();
    await loadTransactionPin();
    await _loadLocalData();
    await fetchProducts();
    await fetchOffers();

    _authSubscription = supabase.Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      final event = data.event;

      if (event == supabase.AuthChangeEvent.signedIn && session != null) {
        _handleAutoLogin();
        _loadUserDataFromDb(session.user.id);
        _startWalletListener(session.user.id);
      } else if (event == supabase.AuthChangeEvent.signedOut) {
        _currentScreen = AppScreen.welcome;
        _walletTokens = 0;
        _cartItems.clear();
        _transactionHistory.clear();
        _ownedProductIds.clear();
        notifyListeners();
        _walletSubscription?.cancel();
        _walletSubscription = null;
      }
    });

    final session = supabase.Supabase.instance.client.auth.currentSession;
    if (session != null) {
      await _handleAutoLogin();
      await _loadUserDataFromDb(session.user.id);
      _startWalletListener(session.user.id);
    } else {
      _currentScreen = AppScreen.welcome;
      notifyListeners();
    }
  }

  // -------------------------------------------------------------------------
  // RESTORED HELPERS (Fixing Undefined Methods)
  // -------------------------------------------------------------------------

  // ✅ RESTORED: Needed by LibraryScreen
  Future<void> refreshData() async {
    notifyListeners();
    await Future.wait([fetchProducts(), fetchOffers()]);

    final user = _authService.currentSupabaseUser;
    if (user != null) {
      await _loadUserDataFromDb(user.id);
      // Ensure wallet is up to date
      await refreshWalletData();
    }
    notifyListeners();
  }

  // ✅ RESTORED: Needed by HomeScreen
  void applyHomeFilter(String f) {
    _homeFilter = f;
    _homeCurrentPage = 1;
    notifyListeners();
  }

  // ✅ RESTORED: Needed by HomeScreen
  void goToPage(int p) {
    _homeCurrentPage = p;
    notifyListeners();
  }

  // ✅ RESTORED: Needed by LockScreen
  void togglePinView(bool show) {
    _showPasswordUnlock = show;
    _pinCode = '';
    notifyListeners();
  }

  // ✅ RESTORED: Needed by ProfileEditScreen
  void setImageProcessing(bool processing) {
    _isImageProcessing = processing;
    notifyListeners();
  }

  // -------------------------------------------------------------------------
  // AUTH LOGIC
  // -------------------------------------------------------------------------

  Future<void> _handleAutoLogin() async {
    try {
      final userProfile = await _authService.fetchUserProfile();
      if (userProfile != null) {
        _currentUser = userProfile;
      }

      final prefs = await SharedPreferences.getInstance();
      bool biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      String? storedPin = await const FlutterSecureStorage().read(key: 'user_pin');
      bool isSecurityActive = biometricEnabled || storedPin != null;

      if ([AppScreen.welcome, AppScreen.login, AppScreen.signup, AppScreen.verifyEmail, AppScreen.splash].contains(_currentScreen)) {
        if (isSecurityActive) {
          navigate(AppScreen.lockUnlock);
        } else {
          if (isProfileIncomplete && !_hasSkippedSetup) {
            navigate(AppScreen.profileSetup);
          } else {
            navigate(AppScreen.home);
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error in auto-login: $e");
      navigate(AppScreen.welcome);
    }
  }

  void handleAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lastPausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_lastPausedTime != null && _autoLockSeconds != -1) {
        final difference = DateTime.now().difference(_lastPausedTime!).inSeconds;
        if (difference > _autoLockSeconds && isPinSet) {
          navigate(AppScreen.lockUnlock);
          return;
        }
      }
      _lastPausedTime = null;

      if ([AppScreen.login, AppScreen.signup, AppScreen.welcome].contains(_currentScreen)) {
        final session = supabase.Supabase.instance.client.auth.currentSession;
        if (session != null) {
          _handleAutoLogin();
        }
      }
    }
  }

  // -------------------------------------------------------------------------
  // PROFILE & SETTINGS ACTIONS
  // -------------------------------------------------------------------------

  // ✅ RESTORED: Needed by ProfileSetupScreen
  Future<void> saveProfile({
    required String fullName,
    String? username,
    required String email,
    required String phoneNumber,
    required String bio,
    String? gender,
    DateTime? dateOfBirth,
    String? profileImageUrl,
  }) async {
    _currentUser = _currentUser.copyWith(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      profileImageUrl: profileImageUrl,
    );
    notifyListeners();

    await _authService.updateUserProfile(_currentUser);

    if (_currentScreen == AppScreen.profileSetup) {
      navigate(AppScreen.home);
    } else {
      navigate(AppScreen.profile);
    }
  }

  // ✅ RESTORED: Needed by ProfileEditScreen
  Future<void> pickAndUploadProfileImage(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (image == null) return;

    setImageProcessing(true);

    try {
      final user = _authService.currentSupabaseUser;
      if (user == null) return;

      final fileBytes = await image.readAsBytes();
      final fileExt = image.path.split('.').last;
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await supabase.Supabase.instance.client.storage
          .from('profiles')
          .uploadBinary(fileName, fileBytes);

      final String publicUrl = supabase.Supabase.instance.client.storage
          .from('profiles')
          .getPublicUrl(fileName);

      _currentUser = _currentUser.copyWith(profileImageUrl: publicUrl);
      await _authService.updateUserProfile(_currentUser);

      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red));
      }
    } finally {
      setImageProcessing(false);
    }
  }

  // ✅ RESTORED: Needed by ProfileSetupScreen
  Future<void> skipProfileSetup() async {
    _hasSkippedSetup = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_skipped_profile_setup', true);
    navigate(AppScreen.home);
  }

  // ✅ RESTORED: Needed by ChangePasswordScreen
  Future<void> changePassword(String currentPassword, String newPassword, BuildContext context) async {
    bool isVerified = await _authService.verifyCurrentPassword(currentPassword);
    if (!isVerified) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Current password incorrect.'), backgroundColor: Colors.red));
      return;
    }
    try {
      await supabase.Supabase.instance.client.auth.updateUser(
        supabase.UserAttributes(password: newPassword),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully!')));
        navigateBack();
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  // ✅ RESTORED: Needed by EmailManagementScreen
  Future<void> updateEmail(String currentPassword, String newEmail, BuildContext context) async {
    bool isVerified = await _authService.verifyCurrentPassword(currentPassword);
    if (!isVerified) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Current password incorrect.'), backgroundColor: Colors.red));
      return;
    }
    try {
      await supabase.Supabase.instance.client.auth.updateUser(supabase.UserAttributes(email: newEmail));
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification link sent to new email address.')));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  // ✅ RESTORED: Needed by SettingsScreen
  Future<void> updateBiometricPreference(bool enable) async {
    bool authenticated = await _authService.authenticateWithBiometrics();
    if (authenticated) {
      final prefs = await SharedPreferences.getInstance();
      if (enable) {
        bool canUse = await _authService.isBiometricsAvailable;
        if (canUse) {
          _isBiometricEnabled = true;
          await prefs.setBool('biometric_enabled', true);
        }
      } else {
        _isBiometricEnabled = false;
        await prefs.setBool('biometric_enabled', false);
      }
      notifyListeners();
    }
  }

  // ✅ RESTORED: Needed by SettingsScreen
  Future<void> updateUserPin(String newPin) async {
    await _authService.saveUserPin(newPin);
    notifyListeners();
  }

  // ✅ RESTORED: Needed by SettingsScreen
  Future<void> resetTransactionPin(String password, String newPin, BuildContext context) async {
    bool isVerified = await _authService.verifyCurrentPassword(password);
    if (!isVerified) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect account password.'), backgroundColor: Colors.red));
      return;
    }
    await setTransactionPin(newPin);
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction PIN reset successfully!')));
  }

  // ✅ RESTORED: Needed by SettingsScreen
  Future<void> requestAccountDeletion(String password, BuildContext context) async {
    bool isVerified = await _authService.verifyCurrentPassword(password);
    if (!isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect password.'), backgroundColor: Colors.red));
      return;
    }
    try {
      await _authService.deleteAccount();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account successfully deleted.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  // -------------------------------------------------------------------------
  // CHECKOUT & TRANSACTIONS (SECURE RPC)
  // -------------------------------------------------------------------------

  Future<void> checkout() async {
    final user = _authService.currentSupabaseUser;
    if (user == null) return;

    try {
      final response = await _dataService.purchaseCart(user.id);

      if (response['success'] == true) {
        debugPrint("Checkout Successful!");
        await refreshWalletData();
        await _loadUserDataFromDb(user.id);
        notifyListeners();
      } else {
        debugPrint("Checkout Failed: ${response['message']}");
      }
    } catch (e) {
      debugPrint("❌ CRITICAL ERROR DURING CHECKOUT: $e");
    }
  }

  Future<void> buyTokens(int amount) async {
    final user = _authService.currentSupabaseUser;
    if (user == null) return;
    try {
      await _dataService.addTokensSecurely(user.id, amount);
      if (_areNotificationsEnabled) {
        _notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: 'Wallet Updated',
          body: 'Success! $amount Tokens purchased.',
        );
      }
    } catch (e) {
      debugPrint("❌ Token Update Failed: $e");
    }
  }

  // -------------------------------------------------------------------------
  // DATA LOADING & ACTIONS
  // -------------------------------------------------------------------------

  Future<void> _loadUserDataFromDb(String userId) async {
    try {
      final ownedIds = await _dataService.getOwnedProductIds(userId);
      _ownedProductIds = List<int>.from(ownedIds);

      _walletTokens = await _dataService.getUserWalletBalance(userId);
      _transactionHistory = await _dataService.getUserTransactions(userId);

      final bookmarkIds = await _dataService.getBookmarkProductIds(userId);
      _bookmarkedProductIds.clear();
      _bookmarkedProductIds.addAll(bookmarkIds);

      final cartIds = await _dataService.getCartProductIds(userId);
      _cartItems.clear();
      for (int id in cartIds) {
        if (_products.any((p) => p.id == id)) {
          final product = _products.firstWhere((p) => p.id == id);
          if (!_cartItems.any((item) => item.id == product.id)) {
            _cartItems.add(product);
          }
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading user data from DB: $e");
    }
  }

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

  Future<void> refreshWalletData() async {
    final user = _authService.currentSupabaseUser;
    if (user == null) return;
    try {
      final results = await Future.wait([
        _dataService.getUserWalletBalance(user.id),
        _dataService.getUserTransactions(user.id),
      ]);
      _walletTokens = results[0] as int;
      _transactionHistory = results[1] as List<Transaction>;
      notifyListeners();
    } catch (e) {
      debugPrint("Error refreshing wallet: $e");
    }
  }

  void _startWalletListener(String userId) {
    _walletSubscription?.cancel();
    _walletSubscription = supabase.Supabase.instance.client
        .from('wallets')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((List<Map<String, dynamic>> data) {
      if (data.isNotEmpty) {
        final newBalance = data.first['balance'] as int;
        if (_walletTokens != newBalance) {
          _walletTokens = newBalance;
          notifyListeners();
        }
      }
    });
  }

  // ✅ RESTORED: Needed by ProductDetailScreen
  Future<void> submitReview(int productId, double rating, String comment) async {
    final user = _authService.currentSupabaseUser;
    if (user == null) return;

    try {
      await _dataService.addProductReview(
        userId: user.id,
        productId: productId,
        rating: rating,
        comment: comment,
      );

      // Update local product state optimistically or re-fetch
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final p = _products[index];
        double newRating = ((p.rating * p.reviewCount) + rating) / (p.reviewCount + 1);
        _products[index] = p.copyWith(rating: newRating, reviewCount: p.reviewCount + 1);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error submitting review: $e");
    }
  }

  // -------------------------------------------------------------------------
  // NAVIGATION & UI
  // -------------------------------------------------------------------------

  void navigate(AppScreen screen, {String? id}) {
    final List<AppScreen> rootScreens = [
      AppScreen.home, AppScreen.library, AppScreen.cart,
      AppScreen.profile, AppScreen.settings, AppScreen.offers, AppScreen.welcome,
    ];

    if (rootScreens.contains(screen)) {
      _historyStack.clear();
    } else if (_currentScreen != screen && _currentScreen != AppScreen.welcome) {
      _historyStack.add(_currentScreen);
    }
    if (id != null) {
      _selectedProductId = id;
    }
    _currentScreen = screen;
    _selectedProductId = (screen == AppScreen.productDetails || screen == AppScreen.reading) ? id : null;
    _selectedOfferId = (screen == AppScreen.offerDetails) ? id : null;

    notifyListeners();
  }

  void navigateBack() {
    if (_historyStack.isEmpty) {
      final session = supabase.Supabase.instance.client.auth.currentSession;
      _currentScreen = (session != null) ? AppScreen.home : AppScreen.welcome;
    } else {
      final previousScreen = _historyStack.removeLast();
      _currentScreen = previousScreen;
      _selectedProductId = null;
      _selectedOfferId = null;
    }
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _currentScreen = AppScreen.home;
    notifyListeners();
  }

  // -------------------------------------------------------------------------
  // FILE / DOWNLOADS
  // -------------------------------------------------------------------------

  Future<String?> getLocalPdfPath(Product product) async {
    final fileName = "${product.id}.pdf";
    if (await _fileService.fileExists(fileName)) {
      return await _fileService.getLocalFilePath(fileName);
    }
    return null;
  }

  Future<void> downloadDocument(Product product) async {
    if (product.pdfUrl == null || product.pdfUrl!.isEmpty) return;
    final fileName = "${product.id}.pdf";
    if (await _fileService.fileExists(fileName)) return;

    _downloadProgress[product.id.toString()] = 0.01;
    notifyListeners();

    try {
      final path = await _fileService.downloadAndSaveDocument(
        url: product.pdfUrl!,
        fileName: fileName,
        onProgress: (progress) {
          _downloadProgress[product.id.toString()] = progress;
          notifyListeners();
        },
      );
      if (path == null) throw "Download returned null";
    } catch (e) {
      debugPrint("Error downloading document: $e");
    } finally {
      _downloadProgress.remove(product.id.toString());
      notifyListeners();
    }
  }

  // ✅ RESTORED: Needed by ProductCard
  void addToLibrary(Product product) {
    // Note: With secure backend, usually "Add to Library" implies purchase.
    // If you support free books, this is fine. If not, this should check payment.
    // We will assume this is for Free Books for now.
    if (!_ownedProductIds.contains(product.id)) {
      _ownedProductIds.add(product.id);
      // We should probably sync this to DB if it's a free claim
      if (product.isFree) {
        final user = _authService.currentSupabaseUser;
        if (user != null) _dataService.addOwnedProduct(user.id, product.id);
      }
      notifyListeners();
    }
  }

  // -------------------------------------------------------------------------
  // USER ACTIONS (Cart, Bookmark, Search)
  // -------------------------------------------------------------------------

  Future<void> addToCart(Product product) async {
    if (_cartItems.any((item) => item.id == product.id)) return;
    _cartItems.add(product);
    notifyListeners();

    final user = _authService.currentSupabaseUser;
    if (user != null) await _dataService.addToCart(user.id, product.id);
  }

  // ✅ RESTORED: Needed by OffersScreen (even if we don't use mock data)
  void addProPackToCart({bool syncToDb = true}) {
    // Safe implementation: Do nothing or show "Coming Soon"
    debugPrint("Pro Pack is currently disabled.");
  }

  // ✅ RESTORED: Needed by OfferDetailScreen
  void addBundleToCart(Offer offer) {
    // Logic to add a "Bundle" product to cart
    // For now we can just ignore or add if you have bundle products
    debugPrint("Bundles are currently disabled.");
  }

  Future<void> removeCartItem(int id) async {
    _cartItems.removeWhere((item) => item.id == id);
    notifyListeners();

    final user = _authService.currentSupabaseUser;
    if (user != null) await _dataService.removeFromCart(user.id, id);
  }

  // In lib/state/app_state.dart

  Future<void> toggleBookmark(int id) async {
    final user = _authService.currentSupabaseUser;

    if (_bookmarkedProductIds.contains(id)) {
      _bookmarkedProductIds.remove(id);
      if (user != null) await _dataService.removeBookmark(user.id, id);
    } else {
      _bookmarkedProductIds.add(id);
      if (user != null) {
        // ✅ Pass the current user's name (or email if name is empty)
        String nameToSend = _currentUser.fullName.isNotEmpty
            ? _currentUser.fullName
            : _currentUser.email;

        await _dataService.addBookmark(user.id, id, nameToSend);
      }
    }
    notifyListeners();
  }

  // ✅ RESTORED: Needed by SearchScreen
  Future<void> loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _searchHistory = prefs.getStringList('search_history') ?? [];
    notifyListeners();
  }

  Future<void> addToSearchHistory(String query) async {
    if (query.isEmpty || _searchHistory.contains(query)) return;
    _searchHistory.insert(0, query);
    if (_searchHistory.length > 5) _searchHistory.removeLast();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_history', _searchHistory);
    notifyListeners();
  }

  // ✅ RESTORED: Needed by SearchScreen
  Future<void> removeFromSearchHistory(String query) async {
    if (_searchHistory.contains(query)) {
      _searchHistory.remove(query);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('search_history', _searchHistory);
      notifyListeners();
    }
  }

  Future<void> clearSearchHistory() async {
    _searchHistory.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_history');
    notifyListeners();
  }

  // -------------------------------------------------------------------------
  // LOCAL DATA & SETTINGS helpers
  // -------------------------------------------------------------------------

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSkippedSetup = prefs.getBool('has_skipped_profile_setup') ?? false;
    _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    await loadSearchHistory();
  }

  Future<void> loadTransactionPin() async {
    final prefs = await SharedPreferences.getInstance();
    _transactionPin = prefs.getString('transaction_pin');
    notifyListeners();
  }

  Future<void> setTransactionPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transaction_pin', pin);
    _transactionPin = pin;
    notifyListeners();
  }

  Future<bool> verifyTransactionPin(String input) async {
    return _transactionPin == input;
  }

  // Settings Setters
  void toggleTheme() { _isDarkTheme = !_isDarkTheme; notifyListeners(); }
  void toggleBiometrics(bool v) { _isBiometricEnabled = v; notifyListeners(); }
  void togglePromoEmails(bool v) { _isPromoEmailEnabled = v; notifyListeners(); }
  Future<void> toggleAppNotifications(bool v) async {
    _areNotificationsEnabled = v;
    if(v) await _notificationService.requestPermissions();
    notifyListeners();
  }

  // Reader Settings
  void setReaderPageFlipping(String m) { _readerPageFlipping = m; _readerSettingsVersion++; notifyListeners(); }
  void setReaderColorMode(String m) { _readerColorMode = m; _readerSettingsVersion++; notifyListeners(); }
  void setReaderFontSize(double s) { _readerFontSize = s; _readerSettingsVersion++; notifyListeners(); }
  void setReaderLineSpacing(double s) { _readerLineSpacing = s; _readerSettingsVersion++; notifyListeners(); }

  // PIN Logic
  void pinEnter(String digit) async {
    if (_pinCode.length < 4) {
      _pinCode += digit;
      notifyListeners();
      if (_pinCode.length == 4) {
        bool isValid = await _authService.verifyPin(_pinCode);
        if (isValid) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (isProfileIncomplete && !_hasSkippedSetup) {
              navigate(AppScreen.profileSetup);
            } else {
              navigate(AppScreen.home);
            }
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

  // Validators
  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) return 'Enter a valid phone number';
    return null;
  }
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) return 'Full name is required';
    if (value.trim().split(' ').length < 2) return 'Enter your full name';
    return null;
  }

  // ✅ RESTORED: Auth Helpers (Sign up / Login)
  Future<void> signup(String email, String password, String fullName, BuildContext context) async {
    try {
      await _authService.signUp(email, password, fullName);
      final session = supabase.Supabase.instance.client.auth.currentSession;
      if (session == null) {
        _pendingEmail = email;
        navigate(AppScreen.verifyEmail);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification email sent.'), backgroundColor: Colors.green));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Signup Failed: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> login(String email, String password, BuildContext context) async {
    try {
      await _authService.signIn(email, password);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login Failed: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google Sign-In Failed: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> verifyOtp(String token, BuildContext context) async {
    if (_pendingEmail == null) return;
    try {
      await _authService.verifyEmailOtp(_pendingEmail!, token);
      _pendingEmail = null;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email verified! Welcome.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification Failed: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}
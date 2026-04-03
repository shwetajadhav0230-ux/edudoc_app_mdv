// lib/utils/constants.dart

class AppConstants {
  static const String razorpayKey = 'rzp_test_BrZoJm8FvGfLhd';
  static const int paisePerToken = 100;
  static const String merchantName = 'EduDoc';
  static const String themeColorHex = '#6366F1';
}

class AppActions {
  // Token & Purchase
  static const String tokensPurchased = 'TOKENS_PURCHASED';
  static const String cartPurchased = 'CART_PURCHASED';
  static const String bundlePurchased = 'BUNDLE_PURCHASED';
  static const String offers = 'offers';
  // Products
  static const String bookDownloaded = 'BOOK_DOWNLOADED';
  static const String bookNotDownloaded = 'BOOK_DOWNLOAD_FAILED';
  static const String addedToCart = 'ADDED_TO_CART';
  static const String removedFromCart = 'REMOVED_FROM_CART';
  static const String addedToWishlist = 'ADDED_TO_WISHLIST';
  static const String addedReview = 'ADDED_REVIEW';

  // User
  static const String userCreated = 'USER_CREATED';
  static const String profileUpdated = 'PROFILE_UPDATED';
}

class EntityTypes {
  static const String products = 'products';
  static const String tokens = 'tokens';
  static const String offers = 'offers';
  static const String reviews = 'reviews';
  static const String users = 'users';
  static const String bookDownloaded = 'BOOK_DOWNLOADED';
}
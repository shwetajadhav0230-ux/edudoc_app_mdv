// lib/services/data_service.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/offer.dart';
import '../models/review.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';

class DataService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// CORE LOGGING FUNCTION
  /// Maps to your public.activity_logs table
  Future<void> logActivity({
    required String action,
    String? entityType,
    int? entityId,
    String? description,
    // coverUrl removed
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      const String defaultRole = 'User';

      await _supabase.from('activity_logs').insert({
        'role': defaultRole,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'description': description,
        // 'cover_url' removed
        'old_data': oldData,
        'new_data': newData,
        'user_id': userId,
      });
    } catch (e) {
      debugPrint("Activity Log Error: $e");
    }
  }

  // --- Products ---

  Future<List<Product>> getProducts() async {
    try {
      final List<dynamic> response = await _supabase
          .from('products')
          .select()
          .order('id', ascending: true);
      return response.map((json) => Product.fromMap(json)).toList();
    } catch (e) {
      debugPrint("Error fetching products: $e");
      return [];
    }
  }

  Future<List<String>> getUniqueCategories() async {
    try {
      final response = await _supabase.from('products').select('category');
      final categories = response.map((item) => item['category'] as String).toSet().toList();
      categories.sort();
      return ['All', ...categories];
    } catch (e) {
      return ['All'];
    }
  }

  // --- Offers ---

  Future<List<Offer>> getOffers() async {
    try {
      final List<dynamic> response = await _supabase.from('offers').select().order('id', ascending: true);
      return response.map((json) => Offer.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // --- Wallet & Transactions ---

  Future<int> getUserWalletBalance(String userId) async {
    try {
      final data = await _supabase.from('wallets').select('balance').eq('user_id', userId).maybeSingle();
      return data != null ? data['balance'] as int : 0;
    } catch (e) {
      return 0;
    }
  }

  Future<List<Transaction>> getUserTransactions(String userId) async {
    try {
      final List<dynamic> data = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return data.map((json) {
        final map = Map<String, dynamic>.from(json);
        map['date'] = json['created_at'] != null ? json['created_at'].toString().split('T')[0] : DateTime.now().toString().split(' ')[0];
        return Transaction.fromMap(map);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addTokensSecurely(String userId, int amount) async {
    try {
      await _supabase.rpc('add_tokens', params: {'row_id': userId, 'count': amount});
      await logActivity(
        action: AppActions.tokensPurchased,
        entityType: EntityTypes.tokens,
        description: 'Purchased $amount tokens',
        newData: {'amount': amount},
      );
    } catch (e) {
      debugPrint('Error adding tokens: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> purchaseCart(String userId) async {
    try {
      final response = await _supabase.rpc('purchase_cart', params: {'p_user_id': userId});
      final result = Map<String, dynamic>.from(response);
      if (result['success'] == true) {
        await logActivity(
          action: AppActions.cartPurchased,
          description: 'User purchased all items in cart',
          newData: result,
        );
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // --- New Bundle Purchase Method ---
  Future<Map<String, dynamic>> purchaseOffer(String userId, int offerId) async {
    try {
      final response = await _supabase.rpc('purchase_offer', params: {
        'p_user_id': userId,
        'p_offer_id': offerId,
      });

      final result = Map<String, dynamic>.from(response);

      if (result['success'] == true) {
        await logActivity(
          action: AppActions.bundlePurchased,
          description: 'Purchased offer #$offerId',
          entityType: EntityTypes.offers,
          entityId: offerId,
        );
      }
      return result;
    } catch (e) {
      debugPrint("Purchase Offer Error: $e");
      return {'success': false, 'message': 'Network or Server Error'};
    }
  }

  // --- Cart, Bookmarks, Owned ---

  Future<List<int>> getCartProductIds(String userId) async {
    try {
      final List<dynamic> data = await _supabase.from('cart').select('product_id').eq('user_id', userId);
      return data.map((e) => e['product_id'] as int).toList();
    } catch (e) { return []; }
  }

  // Updated: Removed coverUrl
  Future<void> addToCart(String userId, int productId) async {
    try {
      await _supabase.from('cart').insert({'user_id': userId, 'product_id': productId});
      await logActivity(
        action: AppActions.addedToCart,
        entityType: EntityTypes.products,
        entityId: productId,
        description: 'Added product #$productId to cart',
      );
    } catch (e) { /* Ignore duplicate */ }
  }

  Future<void> removeFromCart(String userId, int productId) async {
    await _supabase.from('cart').delete().eq('user_id', userId).eq('product_id', productId);
    await logActivity(
      action: AppActions.removedFromCart,
      entityType: EntityTypes.products,
      entityId: productId,
      description: 'Removed product #$productId from cart',
    );
  }

  Future<List<int>> getOwnedProductIds(String userId) async {
    try {
      final List<dynamic> data = await _supabase.from('owned_products').select('product_id').eq('user_id', userId);
      return data.map((e) => e['product_id'] as int).toList();
    } catch (e) { return []; }
  }

  Future<void> addOwnedProduct(String userId, int productId) async {
    try {
      await _supabase.from('owned_products').insert({'user_id': userId, 'product_id': productId});
    } catch (e) { /* Ignore duplicate */ }
  }

  Future<List<int>> getBookmarkProductIds(String userId) async {
    try {
      final List<dynamic> data = await _supabase.from('bookmarks').select('product_id').eq('user_id', userId);
      return data.map((e) => e['product_id'] as int).toList();
    } catch (e) { return []; }
  }

  // Updated: Removed coverUrl
  Future<void> addBookmark(String userId, int productId, String username) async {
    try {
      await _supabase.from('bookmarks').insert({
        'user_id': userId,
        'product_id': productId,
        'username': username,
      });
      await logActivity(
        action: AppActions.addedToWishlist,
        entityType: EntityTypes.products,
        entityId: productId,
        description: 'Product #$productId added to bookmarks',
      );
    } catch (e) {
      debugPrint("Error adding bookmark: $e");
    }
  }

  Future<void> removeBookmark(String userId, int productId) async {
    await _supabase.from('bookmarks').delete().eq('user_id', userId).eq('product_id', productId);
  }

  // --- Downloads ---
  // Updated: Removed coverUrl
  Future<void> logDownload(int productId, String title, bool success) async {
    await logActivity(
      action: success ? AppActions.bookDownloaded : AppActions.bookNotDownloaded,
      entityType: EntityTypes.products,
      entityId: productId,
      description: success ? 'Successfully downloaded $title' : 'Failed to download $title',
    );
  }

  // --- Reviews ---
  Future<void> addProductReview({
    required String userId,
    required int productId,
    required double rating,
    required String comment,
  }) async {
    try {
      final reviewData = {
        'user_id': userId,
        'product_id': productId,
        'rating': rating.toInt(),
        'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
      };
      await _supabase.from('reviews').insert(reviewData);
      await logActivity(
        action: AppActions.addedReview,
        entityType: EntityTypes.reviews,
        entityId: productId,
        description: 'User left a $rating star review',
        newData: reviewData,
      );
    } catch (e) {
      debugPrint('Error posting review: $e');
      rethrow;
    }
  }

  Future<List<Review>> getProductReviews(int productId) async {
    try {
      final List<dynamic> response = await _supabase.from('reviews').select().eq('product_id', productId).order('created_at', ascending: false);
      return response.map((json) => Review.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
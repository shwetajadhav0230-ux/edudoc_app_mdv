import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/offer.dart'; // ✅ IMPORT ADDED

class DataService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetches all products from the Supabase 'products' table
  Future<List<Product>> getProducts() async {
    try {
      final List<dynamic> response = await _supabase
          .from('products')
          .select() // <--- Make sure this matches your table name exactly
          .order('id', ascending: true);

      print("SUPABASE SUCCESS: Found ${response.length} products"); // ✅ Debug success
      return response.map((json) => Product.fromMap(json)).toList();
    } catch (e) {
      print('SUPABASE ERROR: $e'); // ✅ SEE THE REAL ERROR HERE
      return [];
    }
  }

  /// ✅ ADDED: Fetches all offers from the Supabase 'offers' table
  Future<List<Offer>> getOffers() async {
    try {
      print("🔍 ATTEMPTING TO FETCH OFFERS..."); // Debug print

      final List<dynamic> response = await _supabase
          .from('offers')
          .select()
          .order('id', ascending: true);

      print("✅ SUPABASE SUCCESS: Found ${response.length} offers"); // Check count
      print("DATA: $response"); // Check exact data structure

      return response.map((json) => Offer.fromMap(json)).toList();
    } catch (e) {
      print('❌ SUPABASE ERROR: $e'); // See the real error
      return [];
    }
  }
}
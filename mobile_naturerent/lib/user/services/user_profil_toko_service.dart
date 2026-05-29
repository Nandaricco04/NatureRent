import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfilTokoService {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> fetchOwner(dynamic ownerId) async {
    return await _supabase
        .from('owner')
        .select('*, lokasi(nama_kota)')
        .eq('id_owner', ownerId)
        .maybeSingle();
  }

  Future<List<Map<String, dynamic>>> fetchProducts(dynamic ownerId) async {
    final result = await _supabase
        .from('products')
        .select('id_product, name, price_per_day, image_url, rating, stock')
        .eq('owner_id', ownerId)
        .order('id_product', ascending: false);
    return List<Map<String, dynamic>>.from(result);
  }

  double hitungRataRata(List<Map<String, dynamic>> products) {
    if (products.isEmpty) return 0;
    final total = products.fold<double>(
      0,
      (sum, p) => sum + ((p['rating'] ?? 0) as num).toDouble(),
    );
    return total / products.length;
  }
}
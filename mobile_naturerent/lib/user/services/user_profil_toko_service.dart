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
    final products = List<Map<String, dynamic>>.from(result);
    final reviewRatings = await _fetchReviewRatings(
      products.map((product) => product['id_product']).toList(),
    );

    return products.map((product) {
      final productId = product['id_product']?.toString();
      return {
        ...product,
        'rating': reviewRatings[productId] ?? product['rating'] ?? 0,
      };
    }).toList();
  }

  double hitungRataRata(List<Map<String, dynamic>> products) {
    final ratedProducts = products.where((product) {
      return _readDouble(product['rating']) > 0;
    }).toList();
    if (ratedProducts.isEmpty) return 0;

    final total = ratedProducts.fold<double>(
      0,
      (sum, product) => sum + _readDouble(product['rating']),
    );
    return double.parse((total / ratedProducts.length).toStringAsFixed(1));
  }

  Future<Map<String, double>> _fetchReviewRatings(
    List<dynamic> productIds,
  ) async {
    final ids = productIds.where((id) => id != null).toList();
    if (ids.isEmpty) return {};

    final result = await _supabase
        .from('reviews')
        .select('product_id, rating')
        .inFilter('product_id', ids);
    final totals = <String, double>{};
    final counts = <String, int>{};

    for (final row in List<Map<String, dynamic>>.from(result)) {
      final productId = row['product_id']?.toString();
      if (productId == null || productId.isEmpty) continue;

      totals[productId] = (totals[productId] ?? 0) + _readDouble(row['rating']);
      counts[productId] = (counts[productId] ?? 0) + 1;
    }

    return {
      for (final entry in totals.entries)
        entry.key: double.parse(
          (entry.value / (counts[entry.key] ?? 1)).toStringAsFixed(1),
        ),
    };
  }

  double _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse((value ?? '0').toString()) ?? 0;
  }
}

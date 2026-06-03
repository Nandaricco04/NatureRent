import 'package:supabase_flutter/supabase_flutter.dart';

class UserReviewAlatService {
  UserReviewAlatService({SupabaseClient? client})
    : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<void> submitReview({
    required dynamic userId,
    required dynamic productId,
    required dynamic transaksiItemId,
    required int rating,
    required String comment,
  }) async {
    await _supabase.from('reviews').insert({
      'user_id': userId,
      'product_id': productId,
      'transaksi_item_id': transaksiItemId,
      'rating': rating,
      'comment': comment,
    });

    await updateProductRating(productId);
  }

  Future<void> updateProductRating(dynamic productId) async {
    final data = await _supabase
        .from('reviews')
        .select('rating')
        .eq('product_id', productId);
    final reviews = List<Map<String, dynamic>>.from(data);
    if (reviews.isEmpty) return;

    final total = reviews.fold<double>(0, (sum, review) {
      return sum + _readDouble(review['rating']);
    });
    final average = total / reviews.length;

    await _supabase
        .from('products')
        .update({'rating': double.parse(average.toStringAsFixed(1))})
        .eq('id_product', productId);
  }

  double _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse((value ?? '0').toString()) ?? 0;
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerProductService {
  OwnerProductService({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<List<Map<String, dynamic>>> fetchProducts(dynamic ownerId) async {
    final data = await _supabase
        .from('products')
        .select(
          'id_product, category_id, name, description, price_per_day, stock, image_url, rating, kapasitas, iklan, categories(name)',
        )
        .eq('owner_id', ownerId);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> deleteProduct(dynamic productId) async {
    await _supabase.from('products').delete().eq('id_product', productId);
  }
}

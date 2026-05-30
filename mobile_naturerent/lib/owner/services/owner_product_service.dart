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

    final products = List<Map<String, dynamic>>.from(data);
    final adStatusByProductId = await _fetchLatestAdStatusByProductId();

    final mappedProducts = products.map((product) {
      final productId = product['id_product']?.toString();
      final adStatus = productId == null ? null : adStatusByProductId[productId];
      final activeFromAdTable = adStatus == 'aktif';

      return {
        ...product,
        'iklan': _readBool(product['iklan']) || activeFromAdTable,
        'status_iklan': adStatus,
      };
    }).toList();

    mappedProducts.sort((left, right) {
      final adCompare = _adPriority(right).compareTo(_adPriority(left));
      if (adCompare != 0) return adCompare;

      return (left['name'] ?? '')
          .toString()
          .compareTo((right['name'] ?? '').toString());
    });

    return mappedProducts;
  }

  Future<void> deleteProduct(dynamic productId) async {
    await _supabase.from('products').delete().eq('id_product', productId);
  }

  Future<Map<String, String>> _fetchLatestAdStatusByProductId() async {
    try {
      final rows = await _supabase
          .from('iklan_sewa')
          .select('alat_id, status, created_at')
          .order('created_at', ascending: false);

      final statusByProductId = <String, String>{};

      for (final row in List<Map<String, dynamic>>.from(rows)) {
        final productId = row['alat_id']?.toString();
        final status = (row['status'] ?? '').toString();

        if (productId == null || productId.isEmpty || status.isEmpty) {
          continue;
        }

        statusByProductId.putIfAbsent(productId, () => status);
      }

      return statusByProductId;
    } catch (_) {
      return {};
    }
  }

  bool _readBool(dynamic value) {
    if (value is bool) return value;
    return (value ?? '').toString().toLowerCase() == 'true';
  }

  int _adPriority(Map<String, dynamic> product) {
    final status = (product['status_iklan'] ?? '').toString();
    final advertised = _readBool(product['iklan']);

    if (advertised || status == 'aktif') return 4;
    if (status == 'menunggu_verifikasi') return 3;
    if (status == 'ditolak') return 2;
    if (status == 'selesai') return 1;
    return 0;
  }
}

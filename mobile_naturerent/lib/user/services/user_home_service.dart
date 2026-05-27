import 'package:supabase_flutter/supabase_flutter.dart';

class UserHomeCategory {
  const UserHomeCategory({required this.id, required this.name});

  final dynamic id;
  final String name;
}

class UserHomeLocation {
  const UserHomeLocation({required this.id, required this.name});

  final dynamic id;
  final String name;
}

class UserHomeProduct {
  const UserHomeProduct({
    required this.id,
    required this.categoryId,
    required this.ownerId,
    required this.name,
    required this.storeName,
    required this.categoryName,
    required this.locationName,
    required this.pricePerDay,
    required this.stock,
    required this.imageUrl,
    required this.rating,
    required this.rentCount,
  });

  final dynamic id;
  final dynamic categoryId;
  final dynamic ownerId;
  final String name;
  final String storeName;
  final String categoryName;
  final String locationName;
  final double pricePerDay;
  final int stock;
  final String imageUrl;
  final double rating;
  final int rentCount;
}

class UserHomeData {
  const UserHomeData({
    required this.locations,
    required this.categories,
    required this.products,
  });

  final List<UserHomeLocation> locations;
  final List<UserHomeCategory> categories;
  final List<UserHomeProduct> products;
}

class UserHomeService {
  UserHomeService({SupabaseClient? client})
    : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  static const _categoryOrder = [
    'carrier',
    'sleeping bag',
    'kompor',
    'jaket',
    'sepatu',
    'tenda',
  ];

  Future<UserHomeData> fetchHomeData({
    required String? locationName,
    required dynamic categoryId,
  }) async {
    final data = await _fetchCatalog(
      locationName: locationName,
      categoryId: categoryId,
      searchQuery: '',
    );

    return UserHomeData(
      locations: data.locations,
      categories: data.categories,
      products: _balancedPopularProducts(data.products).take(6).toList(),
    );
  }

  Future<UserHomeData> fetchSearchData({
    required String? locationName,
    required dynamic categoryId,
    required String searchQuery,
  }) {
    return _fetchCatalog(
      locationName: locationName,
      categoryId: categoryId,
      searchQuery: searchQuery,
    );
  }

  Future<UserHomeData> _fetchCatalog({
    required String? locationName,
    required dynamic categoryId,
    required String searchQuery,
  }) async {
    final results = await Future.wait([
      _fetchLocations(),
      _fetchCategories(),
      _fetchOwners(),
      _fetchProducts(),
      _fetchRentCounts(),
    ]);

    final locations = results[0] as List<UserHomeLocation>;
    final categories = results[1] as List<UserHomeCategory>;
    final owners = results[2] as List<Map<String, dynamic>>;
    final products = results[3] as List<Map<String, dynamic>>;
    final rentCounts = results[4] as Map<String, int>;

    final ownerById = {
      for (final owner in owners) owner['id_owner']?.toString(): owner,
    };
    final categoryById = {
      for (final category in categories) category.id?.toString(): category,
    };
    final query = searchQuery.trim().toLowerCase();

    final mappedProducts = products
        .map((product) {
          final owner = ownerById[product['owner_id']?.toString()];
          final category = categoryById[product['category_id']?.toString()];

          return UserHomeProduct(
            id: product['id_product'],
            categoryId: product['category_id'],
            ownerId: product['owner_id'],
            name: (product['name'] ?? 'Alat outdoor').toString(),
            storeName: (owner?['nama_toko'] ?? 'Toko Rental').toString(),
            categoryName: category?.name ?? '',
            locationName: (owner?['lokasi_name'] ?? '').toString(),
            pricePerDay: _readDouble(product['price_per_day']),
            stock: _readInt(product['stock']),
            imageUrl: (product['image_url'] ?? '').toString(),
            rating: _readDouble(product['rating']),
            rentCount: rentCounts[product['id_product']?.toString()] ?? 0,
          );
        })
        .where((product) => product.stock > 0)
        .toList();

    var filteredProducts = mappedProducts.where((product) {
      final matchesLocation =
          locationName == null ||
          locationName.isEmpty ||
          product.locationName.toLowerCase() == locationName.toLowerCase();
      final matchesCategory =
          categoryId == null ||
          product.categoryId?.toString() == categoryId.toString();
      final matchesSearch =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.categoryName.toLowerCase().contains(query) ||
          product.storeName.toLowerCase().contains(query);

      return matchesLocation && matchesCategory && matchesSearch;
    }).toList();

    final hasRentData = filteredProducts.any(
      (product) => product.rentCount > 0,
    );
    if (hasRentData) {
      filteredProducts.sort((a, b) {
        final rentCompare = b.rentCount.compareTo(a.rentCount);
        if (rentCompare != 0) return rentCompare;
        return b.rating.compareTo(a.rating);
      });
    } else {
      filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return UserHomeData(
      locations: locations,
      categories: categories,
      products: filteredProducts,
    );
  }

  Future<List<UserHomeLocation>> _fetchLocations() async {
    final data = await _supabase.from('lokasi').select('id_lokasi, nama_kota');

    return List<Map<String, dynamic>>.from(data)
        .map((row) {
          return UserHomeLocation(
            id: row['id_lokasi'],
            name: (row['nama_kota'] ?? '').toString(),
          );
        })
        .where((location) => location.name.isNotEmpty)
        .toList();
  }

  Future<List<UserHomeCategory>> _fetchCategories() async {
    final data = await _supabase.from('categories').select('id_category, name');

    final categories = List<Map<String, dynamic>>.from(data)
        .map((row) {
          return UserHomeCategory(
            id: row['id_category'],
            name: (row['name'] ?? '').toString(),
          );
        })
        .where((category) => _categoryIndex(category.name) != -1)
        .toList();

    categories.sort(
      (a, b) => _categoryIndex(a.name).compareTo(_categoryIndex(b.name)),
    );

    return categories;
  }

  int _categoryIndex(String name) {
    final normalized = _normalizeCategoryName(name);
    for (var i = 0; i < _categoryOrder.length; i++) {
      if (normalized == _categoryOrder[i]) return i;
    }
    return -1;
  }

  String _normalizeCategoryName(String name) {
    final value = name.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (value.contains('carrier')) return 'carrier';
    if (value.contains('sleepingbag')) return 'sleeping bag';
    if (value.contains('kompor')) return 'kompor';
    if (value.contains('jaket')) return 'jaket';
    if (value.contains('sepatu')) return 'sepatu';
    if (value.contains('tenda')) return 'tenda';
    return value;
  }

  Future<List<Map<String, dynamic>>> _fetchOwners() async {
    final owners = await _supabase
        .from('owner')
        .select('id_owner, nama_toko, lokasi_id');
    final locations = await _fetchLocations();
    final locationById = {
      for (final location in locations) location.id?.toString(): location.name,
    };

    return List<Map<String, dynamic>>.from(owners).map((owner) {
      return {
        ...owner,
        'lokasi_name': locationById[owner['lokasi_id']?.toString()] ?? '',
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    final data = await _supabase
        .from('products')
        .select(
          'id_product, category_id, owner_id, name, description, price_per_day, stock, image_url, rating',
        );

    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, int>> _fetchRentCounts() async {
    try {
      final data = await _supabase
          .from('transaksi_item')
          .select('product_id, jumlah');
      final counts = <String, int>{};

      for (final row in List<Map<String, dynamic>>.from(data)) {
        final productId = row['product_id']?.toString();
        if (productId == null || productId.isEmpty) continue;

        counts[productId] = (counts[productId] ?? 0) + _readInt(row['jumlah']);
      }

      return counts;
    } catch (_) {
      return {};
    }
  }

  List<UserHomeProduct> _balancedPopularProducts(
    List<UserHomeProduct> products,
  ) {
    final grouped = <String, List<UserHomeProduct>>{};

    for (final product in products) {
      final storeKey = product.ownerId?.toString() ?? product.storeName;
      grouped.putIfAbsent(storeKey, () => []);
      grouped[storeKey]!.add(product);
    }

    for (final storeProducts in grouped.values) {
      storeProducts.sort(_comparePopularProduct);
    }

    final result = <UserHomeProduct>[];
    for (var round = 0; round < 3 && result.length < 6; round++) {
      final storeKeys = grouped.keys.toList()
        ..sort((a, b) {
          final aProducts = grouped[a]!;
          final bProducts = grouped[b]!;
          final aIndex = round < aProducts.length
              ? round
              : aProducts.length - 1;
          final bIndex = round < bProducts.length
              ? round
              : bProducts.length - 1;
          final aProduct = aProducts[aIndex];
          final bProduct = bProducts[bIndex];
          return _comparePopularProduct(aProduct, bProduct);
        });

      for (final key in storeKeys) {
        final storeProducts = grouped[key]!;
        if (round >= storeProducts.length || result.length >= 6) continue;
        result.add(storeProducts[round]);
      }
    }

    return result;
  }

  int _comparePopularProduct(UserHomeProduct a, UserHomeProduct b) {
    final rentCompare = b.rentCount.compareTo(a.rentCount);
    if (rentCompare != 0) return rentCompare;
    final ratingCompare = b.rating.compareTo(a.rating);
    if (ratingCompare != 0) return ratingCompare;
    return a.name.compareTo(b.name);
  }

  int _readInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '0').toString()) ?? 0;
  }

  double _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse((value ?? '0').toString()) ?? 0;
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/user_home_service.dart';
import '../user_detail_alat.dart';
import 'user_notification_widgets.dart';

class UserHomeHeader extends StatelessWidget {
  const UserHomeHeader({
    super.key,
    required this.name,
    required this.locationName,
    required this.locations,
    required this.searchController,
    required this.onLocationChanged,
    required this.onSearchSubmitted,
    required this.onSearchCleared,
    required this.hasUnreadNotifications,
    required this.onOpenNotifications,
  });

  final String name;
  final String locationName;
  final List<UserHomeLocation> locations;
  final TextEditingController searchController;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onSearchCleared;
  final bool hasUnreadNotifications;
  final VoidCallback onOpenNotifications;

  static const _green = Color(0xFF297B2D);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 54, 16, 26),
      decoration: const BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, Selamat datang',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              _LocationPill(
                locationName: locationName,
                locations: locations,
                onChanged: onLocationChanged,
              ),
              const SizedBox(width: 10),
              UserNotificationBellButton(
                hasUnread: hasUnreadNotifications,
                onTap: onOpenNotifications,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                iconColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 28),
          TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: onSearchSubmitted,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Cari tenda, Carrier, Kompor....',
              hintStyle: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 13,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        searchController.clear();
                        onSearchCleared();
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.18),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationPill extends StatelessWidget {
  const _LocationPill({
    required this.locationName,
    required this.locations,
    required this.onChanged,
  });

  final String locationName;
  final List<UserHomeLocation> locations;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showLocationSheet(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, color: Color(0xFFFF8C22), size: 16),
            const SizedBox(width: 4),
            Text(
              locationName.isEmpty ? 'Lokasi' : locationName,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 11),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLocationSheet(BuildContext context) async {
    if (locations.isEmpty) return;

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _LocationBottomSheet(
          locations: locations,
          selectedLocation: locationName,
        );
      },
    );

    if (selected != null && selected.isNotEmpty) onChanged(selected);
  }
}

class _LocationBottomSheet extends StatefulWidget {
  const _LocationBottomSheet({
    required this.locations,
    required this.selectedLocation,
  });

  final List<UserHomeLocation> locations;
  final String selectedLocation;

  @override
  State<_LocationBottomSheet> createState() => _LocationBottomSheetState();
}

class _LocationBottomSheetState extends State<_LocationBottomSheet> {
  final _searchC = TextEditingController();
  late String _selectedLocation = widget.selectedLocation;

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final query = _searchC.text.trim().toLowerCase();
    final filtered = widget.locations.where((location) {
      return query.isEmpty || location.name.toLowerCase().contains(query);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.72,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pilih kota',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF212121),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F1EF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Color(0xFF77736E)),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE8E2DC)),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
              child: TextField(
                controller: _searchC,
                onChanged: (_) => setState(() {}),
                style: GoogleFonts.poppins(
                  color: const Color(0xFF212121),
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari kota....',
                  hintStyle: GoogleFonts.poppins(
                    color: const Color(0xFF6D6A66),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF77736E),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF4F0EC),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: filtered.length,
                separatorBuilder: (_, _) {
                  return const Divider(height: 1, color: Color(0xFFE8E2DC));
                },
                itemBuilder: (context, index) {
                  final location = filtered[index];
                  final selected = location.name == _selectedLocation;

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedLocation = location.name);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              location.name,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF212121),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (selected)
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF297B2D),
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _selectedLocation.isEmpty
                      ? null
                      : () => Navigator.pop(context, _selectedLocation),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF297B2D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Konfirmasi kota',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserHomeBanner extends StatefulWidget {
  const UserHomeBanner({super.key, required this.destinations});

  final List<UserHomeDestination> destinations;

  @override
  State<UserHomeBanner> createState() => _UserHomeBannerState();
}

class _UserHomeBannerState extends State<UserHomeBanner> {
  final _pageController = PageController();
  Timer? _timer;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void didUpdateWidget(covariant UserHomeBanner oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_hasSameDestinations(oldWidget.destinations, widget.destinations)) {
      _activeIndex = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
      _startAutoSlide();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    if (widget.destinations.length < 2) return;

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;

      final nextIndex = (_activeIndex + 1) % widget.destinations.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  bool _hasSameDestinations(
    List<UserHomeDestination> previous,
    List<UserHomeDestination> current,
  ) {
    if (previous.length != current.length) return false;

    for (var i = 0; i < previous.length; i++) {
      if (previous[i].id?.toString() != current[i].id?.toString()) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final banners = widget.destinations;

    return Container(
      height: 160,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (banners.isEmpty)
            Container(
              color: const Color(0xFFEAF6EC),
              child: const Icon(
                Icons.terrain,
                color: Color(0xFF297B2D),
                size: 46,
              ),
            )
          else
            PageView.builder(
              controller: _pageController,
              itemCount: banners.length,
              onPageChanged: (index) {
                setState(() => _activeIndex = index);
              },
              itemBuilder: (context, index) {
                final banner = banners[index];

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      banner.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return Container(
                          color: const Color(0xFFEAF6EC),
                          child: const Icon(
                            Icons.terrain,
                            color: Color(0xFF297B2D),
                            size: 46,
                          ),
                        );
                      },
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0x99000000)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 12,
                      child: Text(
                        banner.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          shadows: const [
                            Shadow(
                              color: Color(0x99000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          if (banners.length > 1)
            Positioned(
              right: 14,
              top: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(banners.length, (index) {
                  final selected = index == _activeIndex;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: selected ? 18 : 6,
                    height: 6,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: selected ? 0.95 : 0.55,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class UserHomeCategoryList extends StatelessWidget {
  const UserHomeCategoryList({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<UserHomeCategory> categories;
  final dynamic selectedCategoryId;
  final ValueChanged<UserHomeCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected =
              selectedCategoryId?.toString() == category.id?.toString();

          return InkWell(
            onTap: () => onSelected(category),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 54,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFEAF6EC) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF297B2D)
                      : const Color(0xFFE8E2DC),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    _assetForCategory(category.name),
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) {
                      return Icon(
                        Icons.category_outlined,
                        size: 20,
                        color: selected
                            ? const Color(0xFF297B2D)
                            : const Color(0xFF212121),
                      );
                    },
                  ),
                  const SizedBox(height: 3),
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF212121),
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _assetForCategory(String name) {
    final value = name.toLowerCase();
    if (value.contains('carrier') || value.contains('tas')) {
      return 'assets/icon/carrier.png';
    }
    if (value.contains('sleeping')) return 'assets/icon/sleepingbag.png';
    if (value.contains('kompor')) return 'assets/icon/kompor.png';
    if (value.contains('jaket')) return 'assets/icon/jaket.png';
    if (value.contains('sepatu')) return 'assets/icon/sepatu.png';
    if (value.contains('tenda')) return 'assets/icon/tenda.png';
    return 'assets/icon/tenda.png';
  }
}

class UserHomeProductGrid extends StatelessWidget {
  const UserHomeProductGrid({super.key, required this.products});

  final List<UserHomeProduct> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            const Icon(Icons.search_off, color: Color(0xFF297B2D), size: 38),
            const SizedBox(height: 8),
            Text(
              'Produk tidak ditemukan',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Coba ganti lokasi, kategori, atau kata kunci.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF6D6A66),
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        return UserHomeProductCard(product: products[index]);
      },
    );
  }
}

class UserHomeProductCard extends StatelessWidget {
  const UserHomeProductCard({super.key, required this.product});

  final UserHomeProduct product;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserDetailAlat(productId: product.id.toString()),
          ),
        );
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xFFEAF6EC),
                      child: product.imageUrl.isEmpty
                          ? const Icon(
                              Icons.terrain,
                              color: Color(0xFF297B2D),
                              size: 44,
                            )
                          : Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) {
                                return const Icon(
                                  Icons.terrain,
                                  color: Color(0xFF297B2D),
                                  size: 44,
                                );
                              },
                            ),
                    ),
                  ),
                  if (product.advertised)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF297B2D),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Iklan',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF212121),
                    ),
                  ),
                  Text(
                    product.storeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      color: const Color(0xFF6D6A66),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF297B2D),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                            children: [
                              TextSpan(text: _rupiah(product.pricePerDay)),
                              TextSpan(
                                text: '\n/hari',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF6D6A66),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.star,
                        color: Color(0xFFE8752A),
                        size: 16,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        product.rating <= 0
                            ? '-'
                            : product.rating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF212121),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _rupiah(double value) {
    final number = value.round().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < number.length; i++) {
      final reverseIndex = number.length - i;
      buffer.write(number[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) buffer.write('.');
    }

    return 'Rp. $buffer';
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    boxShadow: const [
      BoxShadow(color: Color(0x18000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );
}

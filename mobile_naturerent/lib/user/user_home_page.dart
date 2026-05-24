import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/user_home_service.dart';
import 'widgets/user_home_widgets.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({
    super.key,
    this.name,
    required this.initialLocation,
    required this.onLocationChanged,
    required this.onOpenSearch,
  });

  final String? name;
  final String initialLocation;
  final ValueChanged<String> onLocationChanged;
  final void Function(String query, String locationName, dynamic categoryId)
  onOpenSearch;

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final _service = UserHomeService();
  final _searchC = TextEditingController();

  bool _loading = true;
  String? _errorMessage;
  String _selectedLocation = 'Malang';
  dynamic _selectedCategoryId;
  List<UserHomeLocation> _locations = [];
  List<UserHomeCategory> _categories = [];
  List<UserHomeProduct> _products = [];

  static const _green = Color(0xFF297B2D);

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _loadHomeData();
  }

  @override
  void didUpdateWidget(covariant UserHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLocation != widget.initialLocation &&
        widget.initialLocation != _selectedLocation) {
      _selectedLocation = widget.initialLocation;
      _loadHomeData();
    }
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  Future<void> _loadHomeData() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final data = await _service.fetchHomeData(
        locationName: _selectedLocation,
        categoryId: _selectedCategoryId,
      );

      if (!mounted) return;
      setState(() {
        _locations = data.locations;
        _categories = data.categories;
        _products = data.products;

        if (_locations.isNotEmpty &&
            !_locations.any((location) => location.name == _selectedLocation)) {
          _selectedLocation = _locations.first.name;
          widget.onLocationChanged(_selectedLocation);
        }

        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat produk';
        _loading = false;
      });
    }
  }

  void _changeLocation(String location) {
    setState(() => _selectedLocation = location);
    widget.onLocationChanged(location);
    _loadHomeData();
  }

  void _submitSearch(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    widget.onOpenSearch(query, _selectedLocation, _selectedCategoryId);
  }

  void _selectCategory(UserHomeCategory category) {
    final isSelected =
        _selectedCategoryId?.toString() == category.id?.toString();

    setState(() {
      _selectedCategoryId = isSelected ? null : category.id;
      _searchC.text = isSelected ? '' : category.name;
    });

    if (isSelected) {
      _loadHomeData();
    } else {
      widget.onOpenSearch(category.name, _selectedLocation, category.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.name?.trim().isNotEmpty == true
        ? widget.name!.trim()
        : 'Kelompok 5';

    return RefreshIndicator(
      color: _green,
      onRefresh: _loadHomeData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserHomeHeader(
              name: userName,
              locationName: _selectedLocation,
              locations: _locations,
              searchController: _searchC,
              onLocationChanged: _changeLocation,
              onSearchSubmitted: _submitSearch,
              onSearchCleared: () => setState(() {}),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 26, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const UserHomeBanner(),
                  const SizedBox(height: 26),
                  _SectionTitle('Kategori'),
                  const SizedBox(height: 12),
                  if (_loading && _categories.isEmpty)
                    const _InlineLoading()
                  else
                    UserHomeCategoryList(
                      categories: _categories,
                      selectedCategoryId: _selectedCategoryId,
                      onSelected: _selectCategory,
                    ),
                  const SizedBox(height: 26),
                  _SectionTitle('Populer'),
                  const SizedBox(height: 12),
                  if (_errorMessage != null)
                    _ErrorPanel(message: _errorMessage!)
                  else if (_loading)
                    const _InlineLoading()
                  else
                    UserHomeProductGrid(products: _products),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: const Color(0xFF297B2D),
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _InlineLoading extends StatelessWidget {
  const _InlineLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(child: CircularProgressIndicator(color: Color(0xFF297B2D))),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFEF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

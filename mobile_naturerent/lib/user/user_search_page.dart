import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/user_home_service.dart';
import 'widgets/user_home_widgets.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({
    super.key,
    required this.initialQuery,
    required this.initialLocation,
    required this.initialCategoryId,
    required this.onBack,
  });

  final String initialQuery;
  final String initialLocation;
  final dynamic initialCategoryId;
  final VoidCallback onBack;

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final _service = UserHomeService();
  late final TextEditingController _searchC;

  bool _loading = true;
  String? _errorMessage;
  late String _selectedLocation;
  dynamic _selectedCategoryId;
  String? _selectedSort;
  List<UserHomeProduct> _products = [];

  static const _green = Color(0xFF297B2D);
  static const _searchBarHeight = 36.0;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _selectedCategoryId = widget.initialCategoryId;
    _searchC = TextEditingController(text: widget.initialQuery);
    _loadSearchData();
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  Future<void> _loadSearchData() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final data = await _service.fetchSearchData(
        locationName: _selectedLocation,
        categoryId: _selectedCategoryId,
        searchQuery: _searchC.text,
      );

      if (!mounted) return;
      setState(() {
        _products = _sortProducts(data.products);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat hasil pencarian';
        _loading = false;
      });
    }
  }

  void _submitSearch(String value) {
    if (value.trim().isEmpty) return;
    _loadSearchData();
  }

  void _changeSort(String? sort) {
    setState(() {
      _selectedSort = sort;
      _products = _sortProducts(_products);
    });
  }

  List<UserHomeProduct> _sortProducts(List<UserHomeProduct> products) {
    final result = [...products];
    if (_selectedSort == 'highest') {
      result.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
    } else if (_selectedSort == 'lowest') {
      result.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: _green,
        onRefresh: _loadSearchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: widget.onBack,
                    borderRadius: BorderRadius.circular(17),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, size: 19),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: _searchBarHeight,
                      child: TextField(
                        controller: _searchC,
                        textInputAction: TextInputAction.search,
                        textAlignVertical: TextAlignVertical.center,
                        onSubmitted: _submitSearch,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF212121),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          isDense: false,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FilterButton(
                    height: _searchBarHeight,
                    selectedSort: _selectedSort,
                    onSelected: _changeSort,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              if (_errorMessage != null)
                _SearchMessage(message: _errorMessage!, isError: true)
              else if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 42),
                  child: CircularProgressIndicator(color: _green),
                )
              else
                UserHomeProductGrid(products: _products),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.height,
    required this.onSelected,
    required this.selectedSort,
  });

  final double height;
  final String? selectedSort;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showFilterSheet(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF297B2D),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune, color: Colors.white, size: 17),
            const SizedBox(width: 5),
            Text(
              'Filter',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (selectedSort != null) ...[
              const SizedBox(width: 5),
              const Icon(Icons.check_circle, color: Colors.white, size: 15),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showFilterSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SortFilterSheet(selectedSort: selectedSort);
      },
    );

    if (selected != null) onSelected(selected == 'none' ? null : selected);
  }
}

class _SortFilterSheet extends StatefulWidget {
  const _SortFilterSheet({required this.selectedSort});

  final String? selectedSort;

  @override
  State<_SortFilterSheet> createState() => _SortFilterSheetState();
}

class _SortFilterSheetState extends State<_SortFilterSheet> {
  late String? _tempSort = widget.selectedSort;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Filter Berdasarkan',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF212121),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 38,
                    height: 38,
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
          _SortOptionTile(
            title: 'Termahal',
            selected: _tempSort == 'highest',
            onTap: () {
              setState(() {
                _tempSort = _tempSort == 'highest' ? null : 'highest';
              });
            },
          ),
          const Divider(height: 1, color: Color(0xFFE8E2DC)),
          _SortOptionTile(
            title: 'Termurah',
            selected: _tempSort == 'lowest',
            onTap: () {
              setState(() {
                _tempSort = _tempSort == 'lowest' ? null : 'lowest';
              });
            },
          ),
          const Divider(height: 1, color: Color(0xFFE8E2DC)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 28, 14, 22),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _tempSort ?? 'none'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF297B2D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Konfirmasi',
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
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  const _SortOptionTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF212121),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
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
  }
}

class _SearchMessage extends StatelessWidget {
  const _SearchMessage({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFFEFEF) : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: isError ? Colors.red : const Color(0xFF212121),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

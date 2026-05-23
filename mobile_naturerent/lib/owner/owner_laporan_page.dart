import 'package:flutter/material.dart';

import 'services/owner_laporan_service.dart';
import 'widgets/owner_laporan_widgets.dart';

class OwnerLaporanPage extends StatefulWidget {
  const OwnerLaporanPage({super.key, required this.ownerId});

  final dynamic ownerId;

  @override
  State<OwnerLaporanPage> createState() => _OwnerLaporanPageState();
}

class _OwnerLaporanPageState extends State<OwnerLaporanPage>
    with SingleTickerProviderStateMixin {
  final _service = LaporanService();
  late Future<LaporanBulan> _future;
  late AnimationController _animCtrl;
  late DateTime _selectedMonth;

  static const _green = Color(0xFF297B2D);

  final _bulanList = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  String get _namaBulan {
    return '${_bulanList[_selectedMonth.month - 1]} ${_selectedMonth.year}';
  }

  bool get _isSelectedCurrentMonth {
    final now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    _future = _service.getLaporanBulan(_selectedMonth, widget.ownerId);
  }

  @override
  void didUpdateWidget(covariant OwnerLaporanPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownerId != widget.ownerId) _refresh();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _animCtrl.forward(from: 0);
    setState(() {
      _future = _service.getLaporanBulan(_selectedMonth, widget.ownerId);
    });
    await _future;
  }

  void _changeMonth(int offset) {
    final nextMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + offset,
      1,
    );

    if (offset > 0) {
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month, 1);
      if (nextMonth.isAfter(currentMonth)) return;
    }

    setState(() {
      _selectedMonth = nextMonth;
      _future = _service.getLaporanBulan(_selectedMonth, widget.ownerId);
    });
    _animCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _green,
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: OwnerLaporanCard(
          monthName: _namaBulan,
          isCurrentMonth: _isSelectedCurrentMonth,
          future: _future,
          animationController: _animCtrl,
          onPreviousMonth: () => _changeMonth(-1),
          onNextMonth: () => _changeMonth(1),
          onRefresh: () => _refresh(),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SyaratKebijakanPage extends StatefulWidget {
  const SyaratKebijakanPage({super.key});

  @override
  State<SyaratKebijakanPage> createState() => _SyaratKebijakanPageState();
}

class _SyaratKebijakanPageState extends State<SyaratKebijakanPage> {
  final supabase = Supabase.instance.client;

  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _informasiList = [];

  static const _green = Color(0xFF297B2D);
  static const _background = Color(0xFFF5F2ED);
  static const _labelColor = Color(0xFF212121);

  @override
  void initState() {
    super.initState();
    _loadInformasi();
  }

  Future<void> _loadInformasi() async {
    try {
      final data = await supabase
          .from('informasi')
          .select('id_informasi, title, description')
          .order('id_informasi', ascending: true);

      if (!mounted) return;
      setState(() {
        _informasiList = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat data: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            _buildHeader(context),

            // ── Konten ──────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: _green),
                    )
                  : _error.isNotEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _error,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _loading = true;
                                  _error = '';
                                });
                                _loadInformasi();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Coba Lagi',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _informasiList.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada informasi tersedia.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: _green,
                      onRefresh: _loadInformasi,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: _informasiList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _informasiList[index];
                          return _InformasiCard(
                            title: item['title']?.toString() ?? '',
                            description: item['description']?.toString() ?? '',
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: _background,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: SizedBox(
        width: double.infinity,
        height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: const Color(0xFFD8D3CE)),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 18,
                    color: _labelColor,
                  ),
                ),
              ),
            ),
            Text(
              'Syarat & Kebijakan Privasi',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Card per item informasi ────────────────────────────────────────────────────
class _InformasiCard extends StatelessWidget {
  const _InformasiCard({required this.title, required this.description});

  final String title;
  final String description;
  
  static const _labelColor = Color(0xFF212121);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul di luar kotak, warna hitam
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _labelColor, // hitam
          ),
        ),
        const SizedBox(height: 8),
        // Deskripsi tetap dalam kotak
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD8D3CE).withOpacity(0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: description
                .split('\n\n')
                .map(
                  (paragraph) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      paragraph.trim(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: _labelColor,
                        height: 1.7,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

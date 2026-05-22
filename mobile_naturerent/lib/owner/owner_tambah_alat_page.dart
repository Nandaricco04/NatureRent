import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'widgets/owner_alat_form_widgets.dart';

class OwnerTambahAlatPage extends StatefulWidget {
  const OwnerTambahAlatPage({super.key, required this.ownerId});

  final dynamic ownerId;

  @override
  State<OwnerTambahAlatPage> createState() => _OwnerTambahAlatPageState();
}

class _OwnerTambahAlatPageState extends State<OwnerTambahAlatPage> {
  final supabase = Supabase.instance.client;
  final _imagePicker = ImagePicker();

  final _nameC = TextEditingController();
  final _priceC = TextEditingController();
  final _stockC = TextEditingController();
  final _capacityC = TextEditingController();
  final _descriptionC = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _uploadingImage = false;
  int? _categoryId;
  String? _imageUrl;
  List<Map<String, dynamic>> _categories = [];

  static const _green = Color(0xFF297B2D);
  static const _background = Color(0xFFF5F2ED);
  static const _text = Color(0xFF212121);

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await supabase
          .from('categories')
          .select('id_category, name');
      if (!mounted) return;
      setState(() {
        _categories = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _show('Gagal memuat kategori: $e');
    }
  }

  Future<void> _showImageSourcePicker() async {
    if (_uploadingImage) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(
                    'Ambil dari Kamera',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(
                    'Pilih dari Galeri',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;
    await _pickAndUploadImage(source);
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (picked == null) return;
      setState(() => _uploadingImage = true);

      final bytes = await picked.readAsBytes();

      if (bytes.length > 5 * 1024 * 1024) {
        _show('Ukuran foto maksimal 5 MB');
        return;
      }

      final cleanName = picked.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final ext = cleanName.split('.').last.toLowerCase();
      final path =
          'products/${widget.ownerId}/${DateTime.now().millisecondsSinceEpoch}_$cleanName';
      final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';

      await supabase.storage
          .from('product-images')
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType),
          );

      final url = supabase.storage.from('product-images').getPublicUrl(path);
      if (!mounted) return;
      final previousImageUrl = _imageUrl;
      setState(() => _imageUrl = url);
      await _removeProductImage(previousImageUrl);
      _show('Foto alat berhasil diupload');
    } catch (e) {
      _show('Upload foto gagal: $e');
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  Future<void> _removeProductImage(String? imageUrl) async {
    try {
      if (imageUrl == null) return;

      final path = _extractPathFromPublicUrl(imageUrl);
      if (path == null) return;

      await supabase.storage.from('product-images').remove([path]);
    } catch (_) {
      return;
    }
  }

  String? _extractPathFromPublicUrl(String url) {
    try {
      final segments = Uri.parse(url).pathSegments;
      final bucketIndex = segments.indexOf('product-images');
      if (bucketIndex == -1) return null;
      return segments.sublist(bucketIndex + 1).join('/');
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveProduct() async {
    final name = _nameC.text.trim();
    final price = num.tryParse(_priceC.text.trim());
    final stock = int.tryParse(_stockC.text.trim());
    final capacity = _capacityC.text.trim();
    final description = _descriptionC.text.trim();

    if (name.isEmpty ||
        _categoryId == null ||
        price == null ||
        stock == null ||
        _imageUrl == null) {
      _show('Nama, kategori, harga, stok, dan foto wajib diisi');
      return;
    }

    setState(() => _saving = true);

    try {
      await supabase.from('products').insert({
        'category_id': _categoryId,
        'owner_id': widget.ownerId,
        'name': name,
        'description': description,
        'price_per_day': price,
        'stock': stock,
        'image_url': _imageUrl,
        'rating': 0,
        'kapasitas': capacity,
        'iklan': false,
      });

      if (!mounted) return;
      _show('Alat berhasil disimpan');
      Navigator.pop(context, true);
    } catch (e) {
      _show('Gagal menyimpan alat: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _show(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _nameC.dispose();
    _priceC.dispose();
    _stockC.dispose();
    _capacityC.dispose();
    _descriptionC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProductFormScaffold(
      loading: _loading,
      saving: _saving,
      imageUrl: _imageUrl,
      uploadingImage: _uploadingImage,
      categories: _categories,
      categoryId: _categoryId,
      nameC: _nameC,
      priceC: _priceC,
      stockC: _stockC,
      capacityC: _capacityC,
      descriptionC: _descriptionC,
      title: 'Tambah Alat Baru',
      subtitle: 'Isi semua data dengan lengkap',
      submitText: 'Simpan Alat',
      editMode: false,
      onBack: () => Navigator.pop(context),
      onImagePick: _showImageSourcePicker,
      onCategoryChanged: (value) => setState(() => _categoryId = value),
      onSubmit: _saveProduct,
    );
  }
}

class ProductFormScaffold extends StatelessWidget {
  const ProductFormScaffold({
    required this.loading,
    required this.saving,
    required this.imageUrl,
    required this.uploadingImage,
    required this.categories,
    required this.categoryId,
    required this.nameC,
    required this.priceC,
    required this.stockC,
    required this.capacityC,
    required this.descriptionC,
    required this.title,
    required this.subtitle,
    required this.submitText,
    required this.editMode,
    required this.onBack,
    required this.onImagePick,
    required this.onCategoryChanged,
    required this.onSubmit,
  });

  final bool loading;
  final bool saving;
  final String? imageUrl;
  final bool uploadingImage;
  final List<Map<String, dynamic>> categories;
  final int? categoryId;
  final TextEditingController nameC;
  final TextEditingController priceC;
  final TextEditingController stockC;
  final TextEditingController capacityC;
  final TextEditingController descriptionC;
  final String title;
  final String subtitle;
  final String submitText;
  final bool editMode;
  final VoidCallback onBack;
  final VoidCallback onImagePick;
  final ValueChanged<int?> onCategoryChanged;
  final VoidCallback onSubmit;

  static const _green = Color(0xFF297B2D);
  static const _background = Color(0xFFF5F2ED);
  static const _text = Color(0xFF212121);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator(color: _green))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(23, 24, 23, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OwnerAlatFormHeader(
                      title: title,
                      subtitle: subtitle,
                      onBack: onBack,
                    ),
                    const SizedBox(height: 30),
                    OwnerAlatImagePickerBox(
                      imageUrl: imageUrl,
                      editMode: editMode,
                      uploading: uploadingImage,
                      onTap: uploadingImage ? null : onImagePick,
                    ),
                    const SizedBox(height: 18),
                    _label('Nama Alat', required: true),
                    _field(nameC, 'Tuliskan nama alat...'),
                    const SizedBox(height: 18),
                    _label('Kategori', required: true),
                    _categoryDropdown(),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Harga/Hari', required: true),
                              _field(
                                priceC,
                                '0',
                                keyboardType: TextInputType.number,
                                prefixText: 'Rp  ',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Jumlah Stok', required: true),
                              _field(
                                stockC,
                                '0',
                                keyboardType: TextInputType.number,
                                suffixText: 'unit',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _label('Kapasitas'),
                    _field(capacityC, 'Tuliskan kapasitas'),
                    const SizedBox(height: 18),
                    _label('Deskripsi'),
                    _field(
                      descriptionC,
                      'Tulis deskripsi singkat alat...',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 52),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: saving ? null : onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          disabledBackgroundColor: _green.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                submitText,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(
            color: _text,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          children: [
            TextSpan(text: text),
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    int maxLines = 1,
    String? prefixText,
    String? suffixText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefixText,
        suffixText: suffixText,
        prefixStyle: GoogleFonts.poppins(
          color: _green,
          fontWeight: FontWeight.w700,
        ),
        suffixStyle: GoogleFonts.poppins(
          color: const Color(0xFF8CBF90),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _green),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _green),
        ),
      ),
    );
  }

  Widget _categoryDropdown() {
    return DropdownButtonFormField<int>(
      value: categoryId,
      hint: Text(
        'Pilih Kategori',
        style: GoogleFonts.poppins(
          color: const Color(0xFF9E9E9E),
          fontSize: 14,
        ),
      ),
      items: categories.map((category) {
        return DropdownMenuItem<int>(
          value: category['id_category'] as int,
          child: Text(category['name'].toString()),
        );
      }).toList(),
      onChanged: onCategoryChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _green),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _green),
        ),
      ),
    );
  }
}

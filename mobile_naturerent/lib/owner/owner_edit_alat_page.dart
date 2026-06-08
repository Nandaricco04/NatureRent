import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/app_alerts.dart';
import 'owner_tambah_alat_page.dart';

class OwnerEditAlatPage extends StatefulWidget {
  const OwnerEditAlatPage({
    super.key,
    required this.ownerId,
    required this.product,
  });

  final dynamic ownerId;
  final Map<String, dynamic> product;

  @override
  State<OwnerEditAlatPage> createState() => _OwnerEditAlatPageState();
}

class _OwnerEditAlatPageState extends State<OwnerEditAlatPage> {
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
  String? _oldImageUrl;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fillProduct();
    _loadCategories();
  }

  void _fillProduct() {
    _nameC.text = (widget.product['name'] ?? '').toString();
    _priceC.text = (widget.product['price_per_day'] ?? '').toString();
    _stockC.text = (widget.product['stock'] ?? '').toString();
    _capacityC.text = (widget.product['kapasitas'] ?? '').toString();
    _descriptionC.text = (widget.product['description'] ?? '').toString();
    _imageUrl = (widget.product['image_url'] ?? '').toString();
    if (_imageUrl!.isEmpty) _imageUrl = null;
    _oldImageUrl = _imageUrl;
    _categoryId = widget.product['category_id'] as int?;
  }

  Future<void> _loadCategories() async {
    try {
      final data = await supabase
          .from('categories')
          .select('id_category, name');
      if (!mounted) return;
      setState(() {
        _categories = List<Map<String, dynamic>>.from(data);
        if (_categoryId == null && _categories.isNotEmpty) {
          _categoryId = _categories.first['id_category'] as int;
        }
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
      if (previousImageUrl != null && previousImageUrl != _oldImageUrl) {
        await _removeOldProductImage(previousImageUrl);
      }
      _show('Foto alat berhasil diupload');
    } catch (e) {
      _show('Upload foto gagal: $e');
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
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
      await supabase
          .from('products')
          .update({
            'category_id': _categoryId,
            'owner_id': widget.ownerId,
            'name': name,
            'description': description,
            'price_per_day': price,
            'stock': stock,
            'image_url': _imageUrl,
            'rating': widget.product['rating'] ?? 0,
            'kapasitas': capacity,
            'iklan': widget.product['iklan'] ?? false,
          })
          .eq('id_product', widget.product['id_product']);

      if (_oldImageUrl != null && _oldImageUrl != _imageUrl) {
        await _removeOldProductImage(_oldImageUrl);
        _oldImageUrl = _imageUrl;
      }

      if (!mounted) return;
      _show('Alat berhasil diperbarui');
      Navigator.pop(context, true);
    } catch (e) {
      _show('Gagal menyimpan alat: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _show(String message) {
    AppAlerts.showSnackBar(
      context,
      message: _alertTitle(message),
      subtitle: _alertSubtitle(message),
      type: _alertType(message),
    );
  }

  AppAlertType _alertType(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('berhasil')) return AppAlertType.success;
    if (lower.contains('gagal')) return AppAlertType.error;
    return AppAlertType.warning;
  }

  String _alertTitle(String message) {
    if (message == 'Alat berhasil diperbarui') {
      return 'Alat berhasil diperbarui';
    }
    if (message == 'Foto alat berhasil diupload') return 'Foto alat terupload';
    return message;
  }

  String? _alertSubtitle(String message) {
    if (message == 'Alat berhasil diperbarui') {
      return 'Perubahan alat rental sudah tersimpan.';
    }
    if (message == 'Foto alat berhasil diupload') {
      return 'Foto baru siap dipakai untuk alat ini.';
    }
    return null;
  }

  Future<void> _removeOldProductImage(String? imageUrl) async {
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
      title: 'Edit Alat',
      subtitle: 'Perbarui data alat',
      submitText: 'Simpan Perubahan',
      editMode: true,
      onBack: () => Navigator.pop(context),
      onImagePick: _showImageSourcePicker,
      onCategoryChanged: (value) => setState(() => _categoryId = value),
      onSubmit: _saveProduct,
    );
  }
}

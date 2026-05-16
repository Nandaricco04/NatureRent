import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    _categoryId = widget.product['category_id'] as int?;
  }

  Future<void> _loadCategories() async {
    try {
      final data = await supabase.from('categories').select('id_category, name');
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

  Future<void> _pickAndUploadImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;
      setState(() => _uploadingImage = true);

      final file = result.files.first;
      final bytes = await _readFileBytes(file);
      if (bytes == null) {
        _show('Gagal membaca foto');
        return;
      }

      if (file.size > 5 * 1024 * 1024) {
        _show('Ukuran foto maksimal 5 MB');
        return;
      }

      final ext = (file.extension ?? '').toLowerCase();
      final path =
          '${widget.ownerId}/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';

      await supabase.storage.from('product-images').uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType),
          );

      final url = supabase.storage.from('product-images').getPublicUrl(path);
      if (!mounted) return;
      setState(() => _imageUrl = url);
      _show('Foto alat berhasil diupload');
    } catch (e) {
      _show('Upload foto gagal: $e');
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  Future<Uint8List?> _readFileBytes(PlatformFile file) async {
    if (file.bytes != null) return file.bytes;
    if (file.path == null) return null;
    return File(file.path!).readAsBytes();
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
      await supabase.from('products').update({
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
      }).eq('id_product', widget.product['id_product']);

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
      onImagePick: _pickAndUploadImage,
      onCategoryChanged: (value) => setState(() => _categoryId = value),
      onSubmit: _saveProduct,
    );
  }
}

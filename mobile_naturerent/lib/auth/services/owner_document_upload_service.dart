import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerUploadState {
  String? url;
  String? name;
  String? ext;
  bool loading = false;
}

class OwnerUploadResult {
  const OwnerUploadResult({
    required this.url,
    required this.name,
    required this.ext,
  });

  final String url;
  final String name;
  final String ext;
}

class OwnerDocumentUploadService {
  OwnerDocumentUploadService({SupabaseClient? client})
    : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  static const _bucket = 'owner-docs';

  Future<OwnerUploadResult?> pickAndUpload(
    String folder, {
    String? oldUrl,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final ext = (file.extension ?? '').toLowerCase();
    final fileName = file.name;
    final path = '$folder/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    Uint8List? bytes = file.bytes;
    if (bytes == null && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }
    if (bytes == null) {
      throw Exception('Gagal baca file');
    }

    await _supabase.storage
        .from(_bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: _contentType(ext)),
        );

    final url = _supabase.storage.from(_bucket).getPublicUrl(path);
    await removeOldFile(oldUrl);

    return OwnerUploadResult(url: url, name: fileName, ext: ext);
  }

  Future<void> removeOldFile(String? oldUrl) async {
    if (oldUrl == null) return;

    final oldPath = _extractPathFromPublicUrl(oldUrl);
    if (oldPath == null) return;

    await _supabase.storage.from(_bucket).remove([oldPath]);
  }

  String _contentType(String ext) {
    if (ext == 'pdf') return 'application/pdf';
    if (ext == 'jpg' || ext == 'jpeg') return 'image/jpeg';
    return 'image/png';
  }

  String? _extractPathFromPublicUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final bucketIndex = segments.indexOf(_bucket);
      if (bucketIndex == -1) return null;
      return segments.sublist(bucketIndex + 1).join('/');
    } catch (_) {
      return null;
    }
  }
}

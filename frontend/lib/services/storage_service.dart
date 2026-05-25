import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  StorageService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  static const String _supabaseBucket = 'recipes';

  String _extensionForContentType(String contentType) {
    final ct = contentType.toLowerCase();

    if (ct.contains('png')) return 'png';
    if (ct.contains('webp')) return 'webp';

    return 'jpg';
  }

  Future<String> uploadRecipeImage({
    required String uid,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final ext = _extensionForContentType(contentType);

    final filename = '$timestamp.$ext';

    final path = '$uid/$filename';

    await _supabase.storage
        .from(_supabaseBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: false,
          ),
        );

    final imageUrl = _supabase.storage
        .from(_supabaseBucket)
        .getPublicUrl(path);

    return imageUrl;
  }
}
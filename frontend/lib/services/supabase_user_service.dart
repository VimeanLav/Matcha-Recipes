import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

class SupabaseUserService {
  SupabaseUserService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<void> upsertProfile({
    required String id,
    required String username,
    required String bio,
    required String avatarUrl,
  }) async {
    await _supabase.from('profiles').upsert({
      'id': id,
      'username': username,
      'bio': bio,
      'avatar_url': avatarUrl,
    });
  }

  Stream<UserProfileModel?> streamProfile(String id) {
    return _supabase
        .from('profiles')
        .stream(primaryKey: const ['id'])
        .map((rows) {
          final match = rows.firstWhere(
            (row) => row['id'] == id,
            orElse: () => <String, dynamic>{},
          );
          if (match.isEmpty) return null;
          return UserProfileModel.fromMap(match);
        });
  }

  Future<Map<String, String>> fetchUsernamesByIds(List<String> ids) async {
    if (ids.isEmpty) return {};

    final rows = await _supabase
        .from('profiles')
        .select('id, username')
        .inFilter('id', ids);

    final map = <String, String>{};
    for (final row in rows) {
      final id = (row['id'] ?? '').toString();
      final name = (row['username'] ?? '').toString().trim();
      if (id.isNotEmpty && name.isNotEmpty) {
        map[id] = name;
      }
    }
    return map;
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseFavoriteService {
  SupabaseFavoriteService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Stream<List<Map<String, dynamic>>> streamFavorites(String userId) {
    return _supabase
        .from('favorites')
        .stream(primaryKey: const ['user_id', 'recipe_id'])
        .map((rows) {
          return rows
              .where((row) => row['user_id'] == userId)
              .cast<Map<String, dynamic>>()
              .toList(growable: false);
        });
  }

  Future<void> addFavorite({
    required String userId,
    required String recipeId,
  }) async {
    await _supabase.from('favorites').upsert(
      {
        'user_id': userId,
        'recipe_id': recipeId,
      },
      onConflict: 'user_id,recipe_id',
    );
  }

  Future<void> removeFavorite({
    required String userId,
    required String recipeId,
  }) async {
    await _supabase
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('recipe_id', recipeId);
  }
}

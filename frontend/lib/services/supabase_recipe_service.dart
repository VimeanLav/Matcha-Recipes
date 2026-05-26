import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/recipe_model.dart';

class SupabaseRecipeService {
  SupabaseRecipeService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Stream<List<RecipeModel>> streamRecipes() {
    return _supabase
        .from('recipes')
        .stream(primaryKey: const ['id'])
        .order('created_at', ascending: false)
        .map(
          (rows) =>
              rows.map((row) => RecipeModel.fromMap(row)).toList(growable: false),
        );
  }

  Stream<List<RecipeModel>> streamRecipesByUser(String uid) {
    return _supabase
        .from('recipes')
        .stream(primaryKey: const ['id'])
        .eq('created_by', uid)
        .order('created_at', ascending: false)
        .map(
          (rows) =>
              rows.map((row) => RecipeModel.fromMap(row)).toList(growable: false),
        );
  }

  Future<void> createRecipe(RecipeModel recipe) async {
    await _supabase.from('recipes').insert(recipe.toSupabaseMap());
  }

  Future<void> updateRecipe({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    await _supabase.from('recipes').update(updates).eq('id', id);
  }

  Future<void> deleteRecipe(String id) async {
    await _supabase.from('recipes').delete().eq('id', id);
  }

  Future<List<RecipeModel>> fetchRecipesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final rows = await _supabase
        .from('recipes')
        .select()
        .inFilter('id', ids);
    return rows.map((row) => RecipeModel.fromMap(row)).toList(growable: false);
  }
}

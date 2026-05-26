import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseFollowService {
  SupabaseFollowService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Stream<List<Map<String, dynamic>>> streamFollowers(String userId) {
    return _supabase
        .from('follows')
        .stream(primaryKey: const ['follower_id', 'following_id'])
        .map((rows) {
          return rows
              .where((row) => row['following_id'] == userId)
              .cast<Map<String, dynamic>>()
              .toList(growable: false);
        });
  }

  Stream<List<Map<String, dynamic>>> streamFollowing(String userId) {
    return _supabase
        .from('follows')
        .stream(primaryKey: const ['follower_id', 'following_id'])
        .map((rows) {
          return rows
              .where((row) => row['follower_id'] == userId)
              .cast<Map<String, dynamic>>()
              .toList(growable: false);
        });
  }

  Stream<bool> streamIsFollowing({
    required String followerId,
    required String followingId,
  }) {
    return _supabase
        .from('follows')
        .stream(primaryKey: const ['follower_id', 'following_id'])
        .map((rows) {
          return rows.any(
            (row) =>
                row['follower_id'] == followerId &&
                row['following_id'] == followingId,
          );
        });
  }

  Future<void> follow({
    required String followerId,
    required String followingId,
  }) async {
    await _supabase.from('follows').upsert(
      {
        'follower_id': followerId,
        'following_id': followingId,
      },
      onConflict: 'follower_id,following_id',
    );
  }

  Future<void> unfollow({
    required String followerId,
    required String followingId,
  }) async {
    await _supabase
        .from('follows')
        .delete()
        .eq('follower_id', followerId)
        .eq('following_id', followingId);
  }
}

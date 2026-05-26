import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/supabase_follow_service.dart';
import '../services/supabase_user_service.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

  final _authService = AuthService();
  final _followService = SupabaseFollowService();
  final _userService = SupabaseUserService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = _authService.currentUser;

    if (user == null) {
      return const Center(child: Text('Not signed in'));
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _followService.streamFollowers(user.uid),
                builder: (context, snapshot) {
                  final followers = snapshot.data ??
                      const <Map<String, dynamic>>[];

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (followers.isEmpty) {
                    return Center(
                      child: Text(
                        'No new followers yet.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  final followerIds = followers
                      .map((row) => (row['follower_id'] ?? '').toString())
                      .where((id) => id.isNotEmpty)
                      .toSet()
                      .toList(growable: false);

                  return FutureBuilder<Map<String, String>>(
                    future: _userService.fetchUsernamesByIds(followerIds),
                    builder: (context, nameSnapshot) {
                      final nameMap = nameSnapshot.data ?? const {};
                      return ListView.separated(
                        itemCount: followers.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final row = followers[index];
                          final followerId =
                              (row['follower_id'] ?? '').toString();
                          final when = _formatDate(row['created_at']);
                          final displayName =
                              nameMap[followerId] ?? _shortId(followerId);

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      colorScheme.secondaryContainer,
                                  child: Text(
                                    _initialForName(displayName),
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$displayName followed you',
                                        style:
                                            theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (when.isNotEmpty)
                                        Text(
                                          when,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                _FollowToggle(
                                  currentUser: user,
                                  followerId: followerId,
                                  followService: _followService,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortId(String value) {
    if (value.length <= 10) return value;
    return '${value.substring(0, 5)}...${value.substring(value.length - 3)}';
  }

  String _initialForName(String value) {
    if (value.isEmpty) return 'U';
    return value.substring(0, 1).toUpperCase();
  }

  String _formatDate(Object? raw) {
    if (raw == null) return '';
    if (raw is DateTime) {
      return _formatDateTime(raw);
    }
    if (raw is String) {
      final parsed = DateTime.tryParse(raw);
      if (parsed == null) return '';
      return _formatDateTime(parsed);
    }
    return '';
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$month/$day ${hour}:${minute}';
  }
}

class _FollowToggle extends StatelessWidget {
  const _FollowToggle({
    required this.currentUser,
    required this.followerId,
    required this.followService,
  });

  final User currentUser;
  final String followerId;
  final SupabaseFollowService followService;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (followerId.isEmpty || followerId == currentUser.uid) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<bool>(
      stream: followService.streamIsFollowing(
        followerId: currentUser.uid,
        followingId: followerId,
      ),
      builder: (context, snapshot) {
        final isFollowing = snapshot.data ?? false;
        return TextButton(
          onPressed: () async {
            if (isFollowing) {
              await followService.unfollow(
                followerId: currentUser.uid,
                followingId: followerId,
              );
            } else {
              await followService.follow(
                followerId: currentUser.uid,
                followingId: followerId,
              );
            }
          },
          style: TextButton.styleFrom(
            backgroundColor:
                isFollowing ? colorScheme.surface : const Color(0xFF557A45),
            foregroundColor: isFollowing ? colorScheme.onSurface : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(isFollowing ? 'Unfollow' : 'Follow back'),
        );
      },
    );
  }
}

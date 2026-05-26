import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/recipe_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_follow_service.dart';
import '../services/supabase_recipe_service.dart';
import '../services/supabase_user_service.dart';
import '../widgets/recipe_card.dart';
import 'edit_profile_screen.dart';
import 'recipe_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _recipeService = SupabaseRecipeService();
  final _followService = SupabaseFollowService();
  final _userService = SupabaseUserService();

  String _displayName(User user) {
    final displayName = (user.displayName ?? '').trim();
    if (displayName.isNotEmpty) return displayName;
    final email = (user.email ?? '').trim();
    if (email.isEmpty) return 'User';
    final namePart = email.split('@').first.trim();
    return namePart.isEmpty ? 'User' : namePart;
  }

  String _userEmail(User user) => (user.email ?? '').trim();

  String _initial(User user) {
    final name = _displayName(user).trim();
    return name.isEmpty ? 'U' : name.substring(0, 1).toUpperCase();
  }

  String _joinedText(User user) {
    final createdAt = user.metadata.creationTime;
    if (createdAt == null) return '';
    final month = _monthName(createdAt.month);
    return 'joined $month ${createdAt.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  void _openRecipeDetail(RecipeModel recipe) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)),
    );
  }

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
        child: StreamBuilder<UserProfileModel?>(
          stream: _userService.streamProfile(user.uid),
          builder: (context, profileSnapshot) {
            final profile = profileSnapshot.data;
            final displayName = _displayName(user);
            final username = profile?.username ?? '';
            final bio = profile?.bio ?? '';
            final avatarUrl = profile?.avatarUrl ?? '';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: const Color(0xFFDDE8CF),
                        backgroundImage:
                            avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl.isEmpty
                            ? Text(
                                _initial(user),
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        displayName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        username.isEmpty
                            ? _userEmail(user)
                            : '@$username . ${_joinedText(user)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (bio.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          bio,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      StreamBuilder<List<RecipeModel>>(
                        stream: _recipeService.streamRecipesByUser(user.uid),
                        builder: (context, snapshot) {
                          final recipes =
                              snapshot.data ?? const <RecipeModel>[];
                          return StreamBuilder<List<Map<String, dynamic>>>(
                            stream: _followService.streamFollowers(user.uid),
                            builder: (context, followerSnapshot) {
                              final followers = followerSnapshot.data ??
                                  const <Map<String, dynamic>>[];
                              return StreamBuilder<List<Map<String, dynamic>>>(
                                stream: _followService.streamFollowing(user.uid),
                                builder: (context, followingSnapshot) {
                                  final following = followingSnapshot.data ??
                                      const <Map<String, dynamic>>[];
                                  return Row(
                                    children: [
                                      _StatPill(
                                        label: 'Recipes',
                                        value: '${recipes.length}',
                                      ),
                                      const SizedBox(width: 12),
                                      _StatPill(
                                        label: 'Followers',
                                        value: '${followers.length}',
                                      ),
                                      const SizedBox(width: 12),
                                      _StatPill(
                                        label: 'Following',
                                        value: '${following.length}',
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final updated = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(
                                  user: user,
                                  profile: profile,
                                ),
                              ),
                            );
                            if (updated == true && mounted) {
                              setState(() {});
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            backgroundColor: const Color(0xFF557A45),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Edit profile'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'My recipes',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<List<RecipeModel>>(
                    stream: _recipeService.streamRecipesByUser(user.uid),
                    builder: (context, snapshot) {
                      final recipes =
                          snapshot.data ?? const <RecipeModel>[];
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (recipes.isEmpty) {
                        return Center(
                          child: Text(
                            'No recipes yet.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          return RecipeCard(
                            recipe: recipes[index],
                            onTap: () => _openRecipeDetail(recipes[index]),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

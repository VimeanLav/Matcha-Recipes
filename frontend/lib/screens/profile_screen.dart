import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/recipe_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_recipe_service.dart';
import '../widgets/recipe_card.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final _authService = AuthService();
  final _recipeService = SupabaseRecipeService();

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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => _authService.signOut(),
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),
            _ProfileHeader(user: user, theme: theme, colorScheme: colorScheme),
            const SizedBox(height: 18),
            StreamBuilder<List<RecipeModel>>(
              stream: _recipeService.streamRecipesByUser(user.uid),
              builder: (context, snapshot) {
                final recipes = snapshot.data ?? const <RecipeModel>[];
                return Row(
                  children: [
                    _StatPill(label: 'Recipes', value: '${recipes.length}'),
                    const SizedBox(width: 12),
                    _StatPill(label: '', value: ''),
                    const SizedBox(width: 12),
                    _StatPill(label: '', value: ''),
                  ],
                );
              },
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
                  final recipes = snapshot.data ?? const <RecipeModel>[];
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
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
                      return RecipeCard(recipe: recipes[index]);
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
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.user,
    required this.theme,
    required this.colorScheme,
  });

  final User user;
  final ThemeData theme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final username = (user.displayName ?? '').trim();
    final email = (user.email ?? '').trim();
    final initialSource = username.isNotEmpty ? username : email;
    final initial = initialSource.isNotEmpty
        ? initialSource.substring(0, 1).toUpperCase()
        : 'U';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: colorScheme.secondaryContainer,
            child: Text(
              initial,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username.isNotEmpty ? username : 'User',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: label.isEmpty
            ? const SizedBox(height: 22)
            : Column(
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

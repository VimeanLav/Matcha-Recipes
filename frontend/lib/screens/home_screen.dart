import 'package:flutter/material.dart';

import '../models/recipe_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_recipe_service.dart';
import '../widgets/recipe_card.dart';
import 'add_recipe_screen.dart';
import 'profile_screen.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _openAddRecipe() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
    );
    if (!mounted) return;
    if (created == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Recipe uploaded.')));
    }
  }

  void _onNavTap(int index) {
    if (index == 2) {
      _openAddRecipe();
      return;
    }
    setState(() => _tabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _HomeTab(),
      const _PlaceholderTab(label: 'Saved'),
      const SizedBox.shrink(),
      const _PlaceholderTab(label: 'Notifications'),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: _onNavTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Add',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            selectedIcon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _authService = AuthService();
  final _recipeService = SupabaseRecipeService();
  final _searchController = TextEditingController();
  String _categoryFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openRecipeDetail(RecipeModel recipe) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)),
    );
  }

  String _greetingText(String? email) {
    if (email == null || email.isEmpty) {
      return 'Good morning';
    }
    final namePart = email.split('@').first.trim();
    if (namePart.isEmpty) {
      return 'Good morning';
    }
    return 'Good morning, $namePart';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = _authService.currentUser;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greetingText(user?.email),
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "What's brewing today?",
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search matcha recipes…',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _FilterPill(
                  label: 'All',
                  selected: _categoryFilter == 'All',
                  onTap: () => setState(() => _categoryFilter = 'All'),
                ),
                const SizedBox(width: 10),
                _FilterPill(
                  label: 'Drinks',
                  selected: _categoryFilter == 'Drinks',
                  onTap: () => setState(() => _categoryFilter = 'Drinks'),
                ),
                const SizedBox(width: 10),
                _FilterPill(
                  label: 'Desserts',
                  selected: _categoryFilter == 'Desserts',
                  onTap: () => setState(() => _categoryFilter = 'Desserts'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: StreamBuilder<List<RecipeModel>>(
                stream: _recipeService.streamRecipes(),
                builder: (context, snapshot) {
                  final all = snapshot.data ?? const <RecipeModel>[];
                  final query = _searchController.text.trim().toLowerCase();
                  final filtered = all
                      .where((recipe) {
                        final matchesCategory =
                            _categoryFilter == 'All' ||
                            recipeCategoryToString(recipe.category) ==
                                _categoryFilter;
                        final matchesQuery =
                            query.isEmpty ||
                            recipe.title.toLowerCase().contains(query);
                        return matchesCategory && matchesQuery;
                      })
                      .toList(growable: false);

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Unable to load recipes right now.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'No recipes yet.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  final featured = filtered.first;
                  final popular = filtered.length > 1
                      ? filtered.sublist(1)
                      : const <RecipeModel>[];

                  return ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Featured today',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('See all'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _FeaturedCard(
                        recipe: featured,
                        onTap: () => _openRecipeDetail(featured),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Popular Now',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 1.05,
                            ),
                        itemCount: popular.length,
                        itemBuilder: (context, index) {
                          return RecipeCard(
                            recipe: popular[index],
                            onTap: () => _openRecipeDetail(popular[index]),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                    ],
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

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.recipe, this.onTap});

  final RecipeModel recipe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 180,
          color: colorScheme.surfaceContainerHighest,
          child: Stack(
            children: [
              Positioned.fill(
                child: recipe.imageUrl.isEmpty
                    ? Container(color: colorScheme.surfaceContainerHigh)
                    : Image.network(
                        recipe.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: colorScheme.surfaceContainerHigh,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.image_outlined,
                              color: colorScheme.outline,
                            ),
                          );
                        },
                      ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        colorScheme.scrim.withValues(alpha: 0.65),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        recipeCategoryToString(recipe.category).toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      recipe.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${recipe.timeMinutes} min',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(label));
  }
}

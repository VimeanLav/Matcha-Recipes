import 'package:flutter/material.dart';

import '../models/recipe_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_favorite_service.dart';
import '../services/supabase_recipe_service.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
	const FavoriteScreen({super.key});

	@override
	State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
	final _authService = AuthService();
	final _favoriteService = SupabaseFavoriteService();
	final _recipeService = SupabaseRecipeService();

	Future<void> _openRecipeDetail(RecipeModel recipe) async {
		final result = await Navigator.of(context).push<bool>(
			MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)),
		);
		if (!mounted) return;
		if (result == true) setState(() {});
	}

	Future<void> _removeFavorite({
		required String userId,
		required String recipeId,
	}) async {
		await _favoriteService.removeFavorite(userId: userId, recipeId: recipeId);
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
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Text(
							'Your favorites',
							style: theme.textTheme.titleLarge?.copyWith(
								fontWeight: FontWeight.w700,
							),
						),
						const SizedBox(height: 12),
						Expanded(
							child: StreamBuilder<List<Map<String, dynamic>>>(
								stream: _favoriteService.streamFavorites(user.uid),
								builder: (context, snapshot) {
									final favorites = snapshot.data ??
											const <Map<String, dynamic>>[];
									final recipeIds = favorites
											.map((row) => (row['recipe_id'] ?? '').toString())
											.where((id) => id.isNotEmpty)
											.toSet();

									if (snapshot.connectionState == ConnectionState.waiting) {
										return const Center(child: CircularProgressIndicator());
									}

									return StreamBuilder<List<RecipeModel>>(
										stream: _recipeService.streamRecipes(),
										builder: (context, recipeSnapshot) {
											final all = recipeSnapshot.data ??
													const <RecipeModel>[];
											final recipes = all
													.where((recipe) => recipeIds.contains(recipe.id))
													.toList(growable: false);

											if (recipeSnapshot.connectionState ==
															ConnectionState.waiting &&
													recipes.isEmpty) {
												return const Center(child: CircularProgressIndicator());
											}
											if (recipeIds.isEmpty || recipes.isEmpty) {
												return Center(
													child: Text(
														'No saved recipes yet.',
														style: theme.textTheme.bodyMedium?.copyWith(
															color: colorScheme.onSurfaceVariant,
														),
													),
												);
											}

											return ListView.separated(
												itemCount: recipes.length,
												separatorBuilder: (context, index) =>
														const SizedBox(height: 14),
												itemBuilder: (context, index) {
													final recipe = recipes[index];
													return _FavoriteListCard(
														recipe: recipe,
														onTap: () => _openRecipeDetail(recipe),
														onFavoriteTap: () => _removeFavorite(
															userId: user.uid,
															recipeId: recipe.id,
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
}

class _FavoriteListCard extends StatelessWidget {
	const _FavoriteListCard({
		required this.recipe,
		required this.onTap,
		required this.onFavoriteTap,
	});

	final RecipeModel recipe;
	final VoidCallback onTap;
	final VoidCallback onFavoriteTap;

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);
		final colorScheme = theme.colorScheme;

		return InkWell(
			onTap: onTap,
			borderRadius: BorderRadius.circular(24),
			child: Container(
				padding: const EdgeInsets.all(12),
				decoration: BoxDecoration(
					color: colorScheme.surface,
					borderRadius: BorderRadius.circular(24),
					border: Border.all(color: colorScheme.outlineVariant),
				),
				child: Row(
					children: [
						ClipRRect(
							borderRadius: BorderRadius.circular(18),
							child: SizedBox(
								height: 72,
								width: 72,
								child: recipe.imageUrl.isEmpty
										? Container(color: colorScheme.surfaceContainerHigh)
										: Image.network(
												recipe.imageUrl,
												fit: BoxFit.cover,
											),
							),
						),
						const SizedBox(width: 12),
						Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Container(
										padding: const EdgeInsets.symmetric(
											horizontal: 10,
											vertical: 6,
										),
										decoration: BoxDecoration(
											color: const Color(0xFFDDE8CF),
											borderRadius: BorderRadius.circular(14),
										),
										child: Text(
											recipeCategoryToString(recipe.category).toUpperCase(),
											style: theme.textTheme.labelSmall?.copyWith(
												fontWeight: FontWeight.w700,
											),
										),
									),
									const SizedBox(height: 8),
									Text(
										recipe.title,
										maxLines: 1,
										overflow: TextOverflow.ellipsis,
										style: theme.textTheme.titleMedium?.copyWith(
											fontWeight: FontWeight.w700,
										),
									),
									const SizedBox(height: 6),
									Row(
										children: [
											Icon(
												Icons.schedule,
												size: 16,
												color: colorScheme.onSurfaceVariant,
											),
											const SizedBox(width: 6),
											Text(
												'${recipe.timeMinutes} min',
												style: theme.textTheme.bodySmall?.copyWith(
													color: colorScheme.onSurfaceVariant,
												),
											),
										],
									),
								],
							),
						),
						const SizedBox(width: 10),
						InkWell(
							onTap: onFavoriteTap,
							borderRadius: BorderRadius.circular(20),
							child: Container(
								padding: const EdgeInsets.all(10),
								decoration: BoxDecoration(
									color: colorScheme.surfaceContainerHighest,
									shape: BoxShape.circle,
								),
								child: const Icon(
									Icons.favorite,
									color: Color(0xFF557A45),
								),
							),
						),
					],
				),
			),
		);
	}
}

import 'package:flutter/material.dart';

import '../models/recipe_model.dart';
import '../services/auth_service.dart';
import '../services/supabase_follow_service.dart';
import '../services/supabase_recipe_service.dart';
import 'edit_recipe_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
	const RecipeDetailScreen({super.key, required this.recipe});

	final RecipeModel recipe;

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);
		final colorScheme = theme.colorScheme;
		final authService = AuthService();
		final recipeService = SupabaseRecipeService();
		final followService = SupabaseFollowService();
		final user = authService.currentUser;
		final canFollow = user != null && user.uid != recipe.createdBy;
		final isOwner = user != null && user.uid == recipe.createdBy;

		return Scaffold(
			body: SafeArea(
				child: SingleChildScrollView(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Stack(
								children: [
									AspectRatio(
										aspectRatio: 1,
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
									Positioned(
										top: 12,
										left: 12,
										child: _IconCircleButton(
											icon: Icons.arrow_back,
											onTap: () => Navigator.of(context).pop(),
										),
									),
									Positioned(
										top: 12,
										right: 12,
										child: isOwner
											? _OwnerMenuButton(
												onEdit: () async {
													final edited = await Navigator.of(context).push<bool>(
														MaterialPageRoute(
															builder: (context) =>
																EditRecipeScreen(recipe: recipe),
														),
													);
													if (edited == true && context.mounted) {
														Navigator.of(context).pop(true);
													}
												},
												onDelete: () async {
													final confirm = await showDialog<bool>(
														context: context,
														builder: (context) {
															return AlertDialog(
																title: const Text('Delete recipe'),
																content: const Text(
																	'Are you sure you want to delete this recipe?',
																),
																actions: [
																	TextButton(
																		onPressed: () =>
																			Navigator.of(context).pop(false),
																		child: const Text('Cancel'),
																	),
																	FilledButton(
																		onPressed: () =>
																			Navigator.of(context).pop(true),
																		child: const Text('Delete'),
																	),
																],
															);
														},
													);
													if (confirm != true) return;
													try {
														await recipeService.deleteRecipe(recipe.id);
														if (context.mounted) {
															Navigator.of(context).pop(true);
														}
													} catch (e) {
														if (context.mounted) {
															ScaffoldMessenger.of(context).showSnackBar(
															SnackBar(content: Text('Delete failed: ${e.toString()}')),
														);
														}
													}
												},
											)
											: _IconCircleButton(
													icon: Icons.favorite_border,
													onTap: () {},
												),
									),
								],
							),
							Padding(
								padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											recipeCategoryToString(recipe.category).toUpperCase(),
											style: theme.textTheme.labelMedium?.copyWith(
												color: colorScheme.onSurfaceVariant,
												fontWeight: FontWeight.w700,
											),
										),
										const SizedBox(height: 8),
										Row(
											crossAxisAlignment: CrossAxisAlignment.center,
											children: [
												Expanded(
													child: Text(
														recipe.title,
														style: theme.textTheme.headlineMedium?.copyWith(
															fontWeight: FontWeight.w800,
														),
													),
												),
												if (canFollow)
													StreamBuilder<bool>(
														stream: followService.streamIsFollowing(
															followerId: user!.uid,
															followingId: recipe.createdBy,
														),
														builder: (context, snapshot) {
															final isFollowing = snapshot.data ?? false;
															return TextButton(
																onPressed: () async {
																	if (isFollowing) {
																		await followService.unfollow(
																			followerId: user.uid,
																			followingId: recipe.createdBy,
																		);
																	} else {
																		await followService.follow(
																			followerId: user.uid,
																			followingId: recipe.createdBy,
																		);
																	}
																},
																style: TextButton.styleFrom(
																	backgroundColor: isFollowing
																			? colorScheme.surfaceContainerHighest
																			: const Color(0xFF557A45),
																	foregroundColor: isFollowing
																			? colorScheme.onSurface
																			: Colors.white,
																	shape: RoundedRectangleBorder(
																		borderRadius: BorderRadius.circular(18),
																	),
																	padding: const EdgeInsets.symmetric(
																		horizontal: 16,
																		vertical: 10,
																	),
																),
																child:
																		Text(isFollowing ? 'Following' : 'Follow'),
															);
														},
													),
											],
										),
										const SizedBox(height: 16),
										Row(
											children: [
												_InfoChip(
													icon: Icons.schedule,
													label: '${recipe.timeMinutes} min',
												),
												const SizedBox(width: 10),
												_InfoChip(
													icon: Icons.local_fire_department_outlined,
													label: '${recipe.calories} cal',
												),
											],
										),
										const SizedBox(height: 22),
										Text(
											'Ingredients',
											style: theme.textTheme.titleLarge?.copyWith(
												fontWeight: FontWeight.w700,
											),
										),
										const SizedBox(height: 10),
										Text(
											recipe.ingredients,
											style: theme.textTheme.bodyLarge?.copyWith(
												color: colorScheme.onSurfaceVariant,
												height: 1.4,
											),
										),
										const SizedBox(height: 24),
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

class _InfoChip extends StatelessWidget {
	const _InfoChip({required this.icon, required this.label});

	final IconData icon;
	final String label;

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);
		final colorScheme = theme.colorScheme;

		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
			decoration: BoxDecoration(
				color: colorScheme.surfaceContainerHighest,
				borderRadius: BorderRadius.circular(18),
			),
			child: Row(
				children: [
					Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
					const SizedBox(width: 6),
					Text(
						label,
						style: theme.textTheme.labelLarge?.copyWith(
							fontWeight: FontWeight.w600,
						),
					),
				],
			),
		);
	}
}

class _IconCircleButton extends StatelessWidget {
	const _IconCircleButton({required this.icon, required this.onTap});

	final IconData icon;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		final colorScheme = Theme.of(context).colorScheme;
		return InkWell(
			onTap: onTap,
			borderRadius: BorderRadius.circular(24),
			child: Container(
				padding: const EdgeInsets.all(10),
				decoration: BoxDecoration(
					color: colorScheme.surface.withValues(alpha: 0.9),
					shape: BoxShape.circle,
				),
				child: Icon(icon, color: colorScheme.onSurface),
			),
		);
	}
}

class _OwnerMenuButton extends StatelessWidget {
	const _OwnerMenuButton({required this.onEdit, required this.onDelete});

	final VoidCallback onEdit;
	final VoidCallback onDelete;

	@override
	Widget build(BuildContext context) {
		final colorScheme = Theme.of(context).colorScheme;
		return PopupMenuButton<String>(
			onSelected: (value) {
				if (value == 'edit') {
					onEdit();
				} else if (value == 'delete') {
					onDelete();
				}
			},
			icon: Container(
				padding: const EdgeInsets.all(10),
				decoration: BoxDecoration(
					color: colorScheme.surface.withValues(alpha: 0.9),
					shape: BoxShape.circle,
				),
				child: Icon(Icons.more_horiz, color: colorScheme.onSurface),
			),
			itemBuilder: (context) => const [
				PopupMenuItem(value: 'edit', child: Text('Edit recipe')),
				PopupMenuItem(value: 'delete', child: Text('Delete recipe')),
			],
		);
	}
}

class _FavoriteCircleButton extends StatelessWidget {
	const _FavoriteCircleButton({
		required this.isFavorite,
		required this.onTap,
	});

	final bool isFavorite;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		final colorScheme = Theme.of(context).colorScheme;
		return InkWell(
			onTap: onTap,
			borderRadius: BorderRadius.circular(24),
			child: Container(
				padding: const EdgeInsets.all(10),
				decoration: BoxDecoration(
					color: colorScheme.surface.withValues(alpha: 0.9),
					shape: BoxShape.circle,
				),
				child: Icon(
					isFavorite ? Icons.favorite : Icons.favorite_border,
					color: isFavorite ? const Color(0xFF557A45) : colorScheme.onSurface,
				),
			),
		);
	}
}

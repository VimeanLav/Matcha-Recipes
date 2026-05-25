import 'package:flutter/material.dart';

import '../models/recipe_model.dart';

class RecipeDetailScreen extends StatelessWidget {
	const RecipeDetailScreen({super.key, required this.recipe});

	final RecipeModel recipe;

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);
		final colorScheme = theme.colorScheme;

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
										child: _IconCircleButton(
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
										Text(
											recipe.title,
											style: theme.textTheme.headlineMedium?.copyWith(
												fontWeight: FontWeight.w800,
											),
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

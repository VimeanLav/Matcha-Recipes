import 'package:flutter/material.dart';

import '../models/recipe_model.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  final RecipeModel recipe;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
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
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: InkWell(
                      onTap: onFavoriteTap,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFavorite
                              ? const Color(0xFF557A45)
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Text(
                recipe.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

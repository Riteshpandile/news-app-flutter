import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/article_model.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({
    super.key,
    required this.article,
    required this.onTap,
    this.onBookmark,
    this.isFavorite = false,
  });

  final ArticleModel article;
  final VoidCallback onTap;
  final VoidCallback? onBookmark;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: article.imageUrl!,
                  height: 185,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 185,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => _imageFallback(context),
                ),
              )
            else
              _imageFallback(context),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Text(
                    article.categories.isEmpty
                        ? 'LATEST NEWS'
                        : article.categories.first.toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                IconButton(
                  tooltip: isFavorite ? 'Remove bookmark' : 'Save article',
                  onPressed: onBookmark,
                  icon: Icon(
                    isFavorite
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: isFavorite
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            Text(
              article.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 17,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),

            if (article.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                article.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            const SizedBox(height: 14),

            Row(
              children: [
                const Icon(Icons.language_rounded, size: 15),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    article.sourceName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (article.publishedAt != null)
                  Text(
                    _formatDate(article.publishedAt!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.newspaper_rounded, size: 44),
    );
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');

    return '$day/$month/${localDate.year}';
  }
}

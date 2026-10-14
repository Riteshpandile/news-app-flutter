import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsapp/Core/const/app_colors.dart';
import 'package:newsapp/Features/Articles/models/article_model.dart';
import 'package:newsapp/Features/Favorite/providers/favorites_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NewsDetailsScreen extends ConsumerWidget {
  final ArticleModel article;

  const NewsDetailsScreen({super.key, required this.article});

  Future<void> _openOriginalArticle(BuildContext context) async {
    final uri = Uri.tryParse(article.link);

    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid article link.')));
      return;
    }

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the article.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the article.')),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Recently published';

    final localDate = date.toLocal();

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

    return '${months[localDate.month - 1]} ${localDate.day}, '
        '${localDate.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.isFavorite(article.id);

    final category = article.categories.isNotEmpty
        ? article.categories.first
        : 'News';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 290,
            pinned: true,
            stretch: true,
            backgroundColor: colors.surface,
            leading: Padding(
              padding: const EdgeInsets.all(7),
              child: CircleAvatar(
                backgroundColor: colors.surface.withValues(alpha: 0.94),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.arrow_back_rounded, color: colors.onSurface),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  backgroundColor: colors.surface.withValues(alpha: 0.94),
                  child: IconButton(
                    tooltip: isFavorite ? 'Remove bookmark' : 'Save article',
                    onPressed: () {
                      ref.read(favoritesProvider).toggleFavorite(article);
                    },
                    icon: Icon(
                      isFavorite
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: isFavorite ? colors.primary : colors.onSurface,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background:
                  article.imageUrl != null && article.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: article.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: colors.surfaceContainerHighest,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: colors.surfaceContainerHighest,
                        child: Icon(
                          Icons.newspaper_rounded,
                          size: 60,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Container(
                      color: colors.surfaceContainerHighest,
                      child: Icon(
                        Icons.newspaper_rounded,
                        size: 60,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 15,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _formatDate(article.publishedAt),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    article.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: colors.surfaceContainerHighest,
                        child: Icon(
                          Icons.language_rounded,
                          size: 19,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.sourceName ?? 'News publisher',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Original publisher',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Divider(color: colors.outlineVariant),
                  const SizedBox(height: 20),
                  Text(
                    'The story',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.description?.trim().isNotEmpty == true
                        ? article.description!.trim()
                        : 'No summary is available for this article. '
                              'Visit the original publisher to read more.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.75,
                      color: colors.onSurface,
                    ),
                  ),
                  if (article.content?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 18),
                    Text(
                      article.content!.trim(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.75,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: () => _openOriginalArticle(context),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Read Full Article'),
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppColors.radius),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Continue reading on the publisher’s website.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

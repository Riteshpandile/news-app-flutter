import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsapp/Features/Articles/widgets/news_card.dart';
import 'package:newsapp/Features/Favorite/providers/favorites_provider.dart';
import 'package:newsapp/core/widgets/app_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(favoritesProvider);
    final articles = controller.favorites;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Favorite Stories'),
        centerTitle: false,

        actions: [
          if (articles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${articles.length} saved',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: articles.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bookmark_outline_rounded,
                        size: 46,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Your reading list is empty',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bookmark articles you love and find them '
                      'here whenever you want to read them.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              itemCount: articles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final article = articles[index];

                return NewsCard(
                  article: article,
                  isFavorite: true,
                  onBookmark: () async {
                    await ref.read(favoritesProvider).toggleFavorite(article);
                  },
                  onTap: () async {
                    final uri = Uri.tryParse(article.link);

                    if (uri != null &&
                        (uri.scheme == 'https' || uri.scheme == 'http')) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}

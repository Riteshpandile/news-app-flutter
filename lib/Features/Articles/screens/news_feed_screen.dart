import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:newsapp/Core/Widgets/app_drawer.dart';
import 'package:newsapp/Core/routers/app_router.dart';
import 'package:newsapp/Features/Articles/providers/news_provider.dart';
import 'package:newsapp/Features/Articles/widgets/news_card.dart';
import 'package:newsapp/Features/Articles/widgets/news_feed_header.dart';
import 'package:newsapp/Features/Favorite/providers/favorites_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsFeedScreen extends ConsumerStatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  ConsumerState<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends ConsumerState<NewsFeedScreen> {
  final _scrollController = ScrollController();

  final _categories = const [
    ('top', 'For You'),
    ('business', 'Business'),
    ('technology', 'Technology'),
    ('sports', 'Sports'),
    ('science', 'Science'),
    ('health', 'Health'),
  ];

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(newsProvider).fetchNews();
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.extentAfter < 400) {
      ref.read(newsProvider).fetchNews();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _openArticle(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This article link is invalid.')),
      );
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open article.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final news = ref.watch(newsProvider);
    final favorites = ref.watch(favoritesProvider);

    final theme = Theme.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'News Intelligence',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NewsFeedHeader(),

          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = _categories[index];
                final selected = news.selectedCategory == item.$1;
                final theme = Theme.of(context);
                final colors = theme.colorScheme;

                final categoryIcons = <String, IconData>{
                  'top': Icons.public_rounded,
                  'business': Icons.trending_up_rounded,
                  'technology': Icons.memory_rounded,
                  'sports': Icons.sports_soccer_rounded,
                  'science': Icons.science_rounded,
                  'health': Icons.health_and_safety_rounded,
                  'entertainment': Icons.movie_rounded,
                  'politics': Icons.account_balance_rounded,
                  'world': Icons.language_rounded,
                  'food': Icons.restaurant_rounded,
                };

                final icon =
                    categoryIcons[item.$1.toLowerCase()] ??
                    Icons.article_rounded;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.16),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: ChoiceChip(
                    avatar: Icon(
                      icon,
                      size: 17,
                      color: selected
                          ? colors.onPrimary
                          : colors.onSurfaceVariant,
                    ),
                    label: Text(item.$2),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) {
                      if (!selected) {
                        news.changeCategory(item.$1);
                      }
                    },
                    labelStyle: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected ? colors.onPrimary : colors.onSurface,
                    ),
                    backgroundColor: colors.surface,
                    selectedColor: colors.primary,
                    side: BorderSide(
                      color: selected
                          ? colors.primary
                          : colors.outlineVariant.withValues(alpha: 0.8),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          Expanded(
            child: RefreshIndicator(
              onRefresh: news.refresh,
              child: news.isLoading && news.articles.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : news.hasError && news.articles.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 100),
                        const Icon(Icons.wifi_off_rounded, size: 48),
                        const SizedBox(height: 16),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              news.errorMessage ?? 'Unable to load news.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Center(
                          child: TextButton(
                            onPressed: news.refresh,
                            child: const Text('Try again'),
                          ),
                        ),
                      ],
                    )
                  : news.articles.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Icon(Icons.article_outlined, size: 48),
                        SizedBox(height: 16),
                        Center(child: Text('No articles found.')),
                      ],
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount:
                          news.articles.length +
                          (news.isLoadingMore || news.hasError ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= news.articles.length) {
                          if (news.isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          return Center(
                            child: TextButton(
                              onPressed: news.fetchNews,
                              child: const Text('Retry loading more'),
                            ),
                          );
                        }

                        final article = news.articles[index];

                        return NewsCard(
                          article: article,
                          isFavorite: favorites.isFavorite(article.id),
                          onTap: () async {
                            context.push(
                              AppNavigation.articleDetails,
                              extra: article,
                            );
                          },
                          onBookmark: () async {
                            await ref
                                .read(favoritesProvider)
                                .toggleFavorite(article);
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

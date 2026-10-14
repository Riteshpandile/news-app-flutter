import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:newsapp/Core/network/dio_client.dart';
import 'package:newsapp/Features/Articles/models/article_model.dart';
import 'package:newsapp/Features/Articles/services/news_service.dart';

final newsServiceProvider = Provider<NewsService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return NewsService(dioClient);
});

final newsProvider = ChangeNotifierProvider<NewsController>((ref) {
  return NewsController(ref.watch(newsServiceProvider));
});

class NewsController extends ChangeNotifier {
  NewsController(this._service);

  final NewsService _service;

  final List<ArticleModel> _articles = [];

  List<ArticleModel> get articles => List.unmodifiable(_articles);

  String selectedCategory = 'top';
  String? _nextPage;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasError = false;
  bool hasMore = true;
  String? _currentQuery;
  String? errorMessage;
  Future<void> fetchNews({bool refresh = false, String? query}) async {
    final normalizedQuery = (query?.trim().isEmpty ?? true)
        ? null
        : query!.trim();

    // Store the active query when refreshing or starting a new search.
    if (refresh) {
      _currentQuery = normalizedQuery;
    }

    // Avoid overlapping requests.
    if (isLoading || isLoadingMore) return;

    // Stop if there are no more pages.
    if (!refresh && _articles.isNotEmpty && !hasMore) return;

    if (refresh) {
      _nextPage = null;
      hasMore = true;
    }

    final cursor = refresh ? null : _nextPage;
    final isFirstPage = cursor == null;

    if (isFirstPage) {
      isLoading = true;
      hasError = false;
      errorMessage = null;
    } else {
      isLoadingMore = true;
    }

    notifyListeners();

    try {
      final response = await _service.fetchNews(
        category: selectedCategory,
        query: _currentQuery,
        page: cursor,
      );

      if (response.status != 'success') {
        throw Exception('Unable to load news.');
      }

      if (isFirstPage) {
        _articles.clear();
      }

      final existingIds = _articles.map((article) => article.id).toSet();

      for (final article in response.articles) {
        if (existingIds.add(article.id)) {
          _articles.add(article);
        }
      }

      _nextPage = response.nextPage;
      hasMore =
          _nextPage != null &&
          _nextPage!.isNotEmpty &&
          response.articles.isNotEmpty;

      hasError = false;
      errorMessage = null;
    } catch (e) {
      hasError = true;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> changeCategory(String category) async {
    if (selectedCategory == category) return;

    selectedCategory = category;
    _articles.clear();
    _nextPage = null;
    hasMore = true;
    hasError = false;
    errorMessage = null;

    await fetchNews(refresh: true);
  }

  Future<void> refresh() async {
    await fetchNews(refresh: true);
  }
}

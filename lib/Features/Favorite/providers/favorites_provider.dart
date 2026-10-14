import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';
import 'package:newsapp/Features/Articles/models/article_model.dart';

final favoritesProvider = ChangeNotifierProvider<FavoritesController>((ref) {
  return FavoritesController();
});

class FavoritesController extends ChangeNotifier {
  static const String _boxName = 'favorites';

  late final Box<dynamic> _box;

  FavoritesController() {
    _box = Hive.box<dynamic>(_boxName);
  }

  List<ArticleModel> get favorites {
    return _box.values
        .whereType<Map>()
        .map(
          (item) => ArticleModel.fromStorage(Map<String, dynamic>.from(item)),
        )
        .toList()
        .reversed
        .toList();
  }

  bool isFavorite(String articleId) {
    return _box.containsKey(articleId);
  }

  Future<void> toggleFavorite(ArticleModel article) async {
    if (isFavorite(article.id)) {
      await _box.delete(article.id);
    } else {
      await _box.put(article.id, article.toJson());
    }

    notifyListeners();
  }

  Future<void> removeFavorite(String articleId) async {
    await _box.delete(articleId);
    notifyListeners();
  }
}

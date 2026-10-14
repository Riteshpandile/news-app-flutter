import 'article_model.dart';

class NewsResponseModel {
  final String status;
  final int totalResults;
  final List<ArticleModel> articles;
  final String? nextPage;

  const NewsResponseModel({
    required this.status,
    required this.totalResults,
    required this.articles,
    this.nextPage,
  });

  factory NewsResponseModel.fromJson(Map<String, dynamic> json) {
    final results = json['results'];

    return NewsResponseModel(
      status: json['status']?.toString() ?? 'error',
      totalResults: json['totalResults'] is num
          ? (json['totalResults'] as num).toInt()
          : 0,
      articles: results is List
          ? results
                .whereType<Map>()
                .map(
                  (item) =>
                      ArticleModel.fromJson(Map<String, dynamic>.from(item)),
                )
                .where((article) => article.id.isNotEmpty)
                .toList()
          : const [],
      nextPage: json['nextPage']?.toString(),
    );
  }
}

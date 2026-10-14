class ArticleModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? content;
  final String link;
  final String sourceName;
  final String? sourceUrl;
  final String? sourceIcon;
  final DateTime? publishedAt;
  final List<String> categories;
  final List<String> countries;
  final List<String> creators;
  final String? language;
  final String? sentiment;

  const ArticleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.link,
    required this.sourceName,
    this.imageUrl,
    this.content,
    this.sourceUrl,
    this.sourceIcon,
    this.publishedAt,
    this.categories = const [],
    this.countries = const [],
    this.creators = const [],
    this.language,
    this.sentiment,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content']?.toString();

    return ArticleModel(
      id: json['article_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled article',
      description: json['description']?.toString() ?? '',
      imageUrl: _nullableString(json['image_url']),
      content: _validContent(rawContent),
      link: json['link']?.toString() ?? '',
      sourceName: json['source_name']?.toString() ?? 'Unknown source',
      sourceUrl: _nullableString(json['source_url']),
      sourceIcon: _nullableString(json['source_icon']),
      publishedAt: DateTime.tryParse(json['pubDate']?.toString() ?? ''),
      categories: _stringList(json['category']),
      countries: _stringList(json['country']),
      creators: _stringList(json['creator']),
      language: _nullableString(json['language']),
      sentiment: _nullableString(json['sentiment']),
    );
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }

    return text;
  }

  static String? _validContent(String? value) {
    if (value == null) return null;

    final normalized = value.trim();

    if (normalized.isEmpty ||
        normalized.toUpperCase().contains('ONLY AVAILABLE IN PAID PLANS') ||
        normalized.toUpperCase().contains(
          'ONLY AVAILABLE IN CORPORATE PLANS',
        )) {
      return null;
    }

    return normalized;
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];

    return value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  factory ArticleModel.fromStorage(Map<dynamic, dynamic> json) {
    return ArticleModel.fromJson(Map<String, dynamic>.from(json));
  }

  Map<String, dynamic> toJson() {
    return {
      'article_id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'content': content,
      'link': link,
      'source_name': sourceName,
      'source_url': sourceUrl,
      'source_icon': sourceIcon,
      'pubDate': publishedAt?.toIso8601String(),
      'category': categories,
      'country': countries,
      'creator': creators,
      'language': language,
      'sentiment': sentiment,
    };
  }
}

import 'package:dio/dio.dart';

import '../../../Core/const/api_constants.dart';
import '../../../Core/network/dio_client.dart';
import '../models/news_response_model.dart';

class NewsService {
  NewsService(this._client);

  final DioClient _client;

  Future<NewsResponseModel> fetchNews({
    String category = 'top',
    String? query,
    String? page,
  }) async {
    if (ApiConstants.apiKey.isEmpty) {
      throw Exception('API key missing. Configure NEWS_API_KEY.');
    }

    try {
      final response = await _client.dio.get(
        ApiConstants.latestNews,
        queryParameters: {
          'apikey': ApiConstants.apiKey,
          'language': 'en',
          'country': 'in',
          if (category != 'top') 'category': category,
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
          if (page != null && page.isNotEmpty) 'page': page,
        },
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response received from news API.');
      }

      if (data['status'] != 'success') {
        throw Exception(data['results']?.toString() ?? 'Unable to fetch news.');
      }

      return NewsResponseModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw Exception('API limit reached. Please try again later.');
      }

      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('API key is invalid or access is restricted.');
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Request timed out. Please try again.');
      }

      if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection.');
      }

      throw Exception('Unable to load news. Please try again.');
    }
  }
}

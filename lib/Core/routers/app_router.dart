import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:newsapp/Features/Articles/models/article_model.dart';
import 'package:newsapp/Features/Articles/screens/news_details_screen.dart';
import 'package:newsapp/Features/Articles/screens/news_feed_screen.dart';
import 'package:newsapp/Features/Auth/screens/login_screen.dart';
import 'package:newsapp/Features/Auth/screens/signup_screen.dart';
import 'package:newsapp/Features/Favorite/screens/favorites_screen.dart';

final appRouter = GoRouter(
  initialLocation:
      Hive.box('settings').get('isLoggedIn', defaultValue: false) as bool
      ? AppNavigation.news
      : AppNavigation.login,
  routes: [
    GoRoute(
      path: AppNavigation.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppNavigation.signup,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppNavigation.news,
      builder: (context, state) => const NewsFeedScreen(),
    ),
    GoRoute(
      path: AppNavigation.favorites,
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: AppNavigation.articleDetails,
      builder: (context, state) {
        final article = state.extra as ArticleModel;

        return NewsDetailsScreen(article: article);
      },
    ),
  ],
);

class AppNavigation {
  static String login = '/login';
  static String signup = '/signup';
  static String news = '/news';
  static String favorites = '/favorites';
  static String search = 'search';
  static const String articleDetails = '/article-details';
}

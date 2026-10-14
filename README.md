# News Intelligence App

A Flutter news application built with a feature-based architecture. It
fetches news from NewsData.io, supports keyword search and category
filtering, displays article details, and lets users save stories locally
using Hive.

## Table of Contents

-   [Features](#features)
-   [Tech Stack](#tech-stack)
-   [Architecture](#architecture)
-   [Project Structure](#project-structure)
-   [Application Flow](#application-flow)
-   [News API Integration](#news-api-integration)
-   [Article Details Flow](#article-details-flow)
-   [Favorites and Local Storage](#favorites-and-local-storage)
-   [Authentication](#authentication)
-   [Getting Started](#getting-started)
-   [Running the App](#running-the-app)
-   [Important Notes](#important-notes)

## Features

-   News feed powered by the NewsData.io API.
-   Category-based news browsing.
-   Keyword search through the news API.
-   Debounced search input to reduce repeated API requests.
-   Article details screen with image, title, source, publication date,
    category, and available summary/content.
-   Button to open the original publisher's article in the external
    browser.
-   Bookmark articles and remove bookmarks.
-   Persistent favorites stored locally with Hive.
-   Local demo signup/login and session persistence.
-   Responsive, theme-aware UI with reusable news cards and category
    chips.
-   Pagination using the API's `nextPage` cursor.
-   Loading, empty, and error states.

## Tech Stack

-   **Flutter / Dart** --- mobile app UI and application code.
-   **flutter_riverpod** --- state management and provider access.
-   **Dio** --- HTTP requests to the news API.
-   **Hive / hive_flutter** --- local storage for settings, demo users,
    and saved articles.
-   **GoRouter** --- declarative navigation.
-   **cached_network_image** --- article image loading and caching.
-   **url_launcher** --- open publisher links in the browser.
-   **crypto** --- SHA-256 hashing for the local demo authentication
    flow.

Use the versions declared in the project's `pubspec.yaml` as the source
of truth.

## Architecture

The project uses a **simple feature-based architecture** rather than a
large Clean Architecture setup. Files are grouped by the feature they
serve, while shared infrastructure is placed under `core/` and app-wide
storage helpers can live under `services/`.

### Main responsibilities

  -----------------------------------------------------------------------
  Area                                Responsibility
  ----------------------------------- -----------------------------------
  `core/const/`                       Shared constants, colors, and API
                                      configuration

  `core/network/`                     Dio client and network
                                      configuration

  `core/router/`                      Route paths and GoRouter setup

  `core/utils/`                       Shared utility functions

  `core/widgets/`                     Reusable widgets such as the app
                                      drawer

  `features/auth/`                    Signup, login, and local session
                                      state

  `features/article/`                 News API integration, models, feed,
                                      reusable cards, and details

  `features/favorites/`               Saved-article state and favorites
                                      screen

  `services/`                         Shared storage-related services
  -----------------------------------------------------------------------

### Data flow

``` text
Screen / Widget
      |
      v
Riverpod provider or controller
      |
      v
Feature service (for network requests)
      |
      v
Dio client
      |
      v
NewsData.io API
      |
      v
Response model -> Article model -> UI
```

For local favorites, the flow is shorter:

``` text
Bookmark tap
    |
    v
FavoritesController
    |
    v
Hive favorites box
    |
    v
notifyListeners()
    |
    v
News card and Favorites screen rebuild
```

## Project Structure

The following is the intended feature layout. Names can vary slightly
depending on the current implementation.

``` text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── const/
│   │   ├── api_constants.dart
│   │   └── app_colors.dart
│   ├── network/
│   │   └── dio_client.dart
│   ├── router/
│   │   └── app_navigation.dart
│   ├── utils/
│   └── widgets/
│       └── app_drawer.dart
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── providers/
│   │   └── models/
│   ├── article/
│   │   ├── screens/
│   │   │   ├── news_feed_screen.dart
│   │   │   └── news_details_screen.dart
│   │   ├── widgets/
│   │   │   ├── news_card.dart
│   │   │   └── news_feed_header.dart
│   │   ├── providers/
│   │   │   └── news_provider.dart
│   │   ├── models/
│   │   │   ├── article_model.dart
│   │   │   └── news_response_model.dart
│   │   └── services/
│   │       └── news_service.dart
│   └── favorites/
│       ├── screens/
│       │   └── favorites_screen.dart
│       └── providers/
│           └── favorites_provider.dart
└── services/
    └── storage_service.dart
```

## Application Flow

### 1. Startup

1.  `main.dart` initializes Flutter.
2.  Hive is initialized and the required boxes are opened before
    `runApp()`.
3.  The app is wrapped in `ProviderScope` so Riverpod providers are
    available.
4.  GoRouter selects the initial screen based on the stored demo login
    session, if that behavior is configured in the router.

Typical Hive boxes used by this app:

-   `settings` --- login state and current demo account information.
-   `users` --- local demo account records.
-   `favorites` --- saved article maps keyed by article ID.

### 2. Authentication

The login and signup screens use the authentication controller/provider
to validate local demo credentials and persist session state in Hive.
Logging out clears the stored session and navigates back to login.

This is a local demonstration flow, not a production authentication
system. See [Important Notes](#important-notes).

### 3. News feed

1.  The news screen watches the news controller/provider.
2.  The controller calls `NewsService`.
3.  `NewsService` builds the request using the shared Dio client.
4.  The response is parsed into `NewsResponseModel` and `ArticleModel`
    objects.
5.  The screen renders articles using the reusable `NewsCard`.
6.  Pull-to-refresh reloads the first page.
7.  Scrolling near the bottom requests the next page using the API
    cursor.

### 4. Categories

Category chips update the selected category in the news controller and
request a refreshed first page. The `top` category is treated as the
default/latest feed category; other categories are sent to the API as
category filters.

### 5. Search

The header's search icon expands a text field. Text changes are
debounced before calling the controller with a search query. The service
passes the keyword to NewsData.io through its `q` query parameter.

When a new search starts, the feed should reset the page cursor and
replace old results. Clearing the field should refresh the feed without
a query. Category changes should preserve the current query if that
behavior is enabled in the controller.

## News API Integration

The app uses the NewsData.io latest-news endpoint:

``` text
GET https://newsdata.io/api/1/latest
```

Common query parameters:

  Parameter    Purpose
  ------------ -----------------------------------
  `apikey`     API key for NewsData.io
  `language`   Language filter, for example `en`
  `country`    Country filter, for example `in`
  `category`   Optional category filter
  `q`          Optional keyword search
  `page`       Cursor for fetching another page

The response's `results` array is converted into article models. The
`nextPage` value is an opaque pagination cursor and should be passed
back to the API as returned; do not attempt to calculate it.

### API key configuration

The API configuration can read the key using Dart's compile-time
environment:

``` dart
class ApiConstants {
  static const String baseUrl = 'https://newsdata.io/api/1';
  static const String apiKey =
      String.fromEnvironment('NEWS_API_KEY');
  static const String latestNews = '/latest';
}
```

Pass a key at run time:

``` bash
flutter run --dart-define=NEWS_API_KEY=YOUR_API_KEY
```

Do not commit a real key to source control. A key compiled into a mobile
app can still be extracted; use a backend proxy to protect it in
production. If a key has been shared publicly, rotate it in the provider
dashboard.

The free API plan may impose quotas, rate limits, or limits on available
article content. The app should show appropriate error states when a
request fails.

## Article Details Flow

The details screen is opened when the user taps a news card. Navigation
passes the selected `ArticleModel` through GoRouter's `extra` field,
avoiding an additional API request just to display the selected article.

``` text
NewsCard tap
    |
    v
GoRouter /article-details (article passed as extra)
    |
    v
NewsDetailsScreen
    |
    +--> Display image, category, date, source, title and summary
    |
    +--> Bookmark / unbookmark through FavoritesController
    |
    +--> Read Full Article -> url_launcher -> publisher website
```

The details screen displays the data available in the API response:

-   Hero image, when available.
-   Category and publication date.
-   Article title and publisher.
-   Description or summary.
-   Content only when the API supplies usable content.
-   A **Read Full Article** button that opens the original HTTP/HTTPS
    publisher URL externally.
-   A bookmark action that uses the same favorites provider as the feed.

Some NewsData.io responses may contain a placeholder such as
`ONLY AVAILABLE IN PAID PLANS` for article content. The model should
filter such placeholders and the UI should direct the reader to the
original publisher when full content is unavailable.

## Favorites and Local Storage

The favorites controller uses the Hive box named `favorites`. Articles
are stored as maps using their article ID as the key, which prevents
duplicate saved entries.

### Save an article

1.  The user taps the bookmark icon.
2.  The controller checks whether the article ID is already in Hive.
3.  If not saved, it stores `article.toJson()` under the article ID.
4.  The controller calls `notifyListeners()`.
5.  Widgets watching the provider rebuild and show the filled bookmark
    icon.

### Remove an article

If the article is already saved, tapping the bookmark deletes its Hive
entry. The feed and favorites screen should then show the unsaved state.

### Favorites screen

The Favorites screen reads stored article maps, reconstructs
`ArticleModel` objects, and displays them using the same reusable news
card. Selecting a saved card opens the same details screen. The list
persists across app restarts because Hive stores the data locally.

Favorites are stored on the device. Unless the app explicitly namespaces
saved articles by account, favorites are shared by local accounts on
that device.

## Getting Started

### Prerequisites

-   Flutter SDK installed and available on your `PATH`.
-   Android Studio, VS Code, or another Flutter-compatible editor.
-   An emulator or physical Android/iOS device.
-   A NewsData.io API key.

### Install dependencies

Clone or open the project, then run:

``` bash
flutter pub get
```

Ensure `main.dart` initializes Hive and opens all required boxes before
the app starts.

### Run in development

``` bash
flutter run --dart-define=NEWS_API_KEY=YOUR_API_KEY
```

For VS Code debugging, the same `--dart-define` can be added to the
Flutter launch configuration's `toolArgs`.

### Build an Android APK

``` bash
flutter build apk --release --dart-define=NEWS_API_KEY=YOUR_API_KEY
```

Use the regenerated API key for local testing if a previous key was
exposed. Avoid placing real keys in committed configuration files.

## Important Notes

-   **Demo authentication:** storing credentials locally, even as
    hashes, is not a replacement for secure server-side authentication.
    Plain SHA-256 is not an appropriate password-storage scheme for
    production.
-   **API key protection:** Dart compile-time environment values are not
    a secure vault. Production apps should make protected API calls
    through a backend.
-   **Article availability:** article body content depends on what the
    API returns and the subscription plan. The original publisher
    remains the source for the complete article.
-   **Network handling:** account for connectivity failures, API
    quota/rate limits, invalid keys, and empty results.
-   **Request races:** if users type a new search while a request is
    already in flight, make sure stale responses cannot overwrite newer
    search results. Consider request cancellation or a
    request-generation token.
-   **Hive lifecycle:** open boxes before providers or widgets attempt
    to read them.
-   **Model compatibility:** the `ArticleModel` JSON serialization and
    storage deserialization methods must remain compatible with the
    fields saved in Hive.
-   **Route consistency:** ensure the registered route paths match
    `AppNavigation` constants and that the details route receives an
    `ArticleModel` through `state.extra`.

## Suggested Future Improvements

-   Add automated tests for models, API service, pagination, search, and
    favorites.
-   Add request cancellation for changing search queries.
-   Add pagination retry and offline-friendly error handling.
-   Add per-account favorites if multiple accounts are supported.
-   Add secure backend authentication and API key protection before
    production release.
-   Add CI/CD and release automation.

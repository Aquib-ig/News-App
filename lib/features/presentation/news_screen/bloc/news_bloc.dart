import "dart:developer";
import "package:dio/dio.dart";
import "package:equatable/equatable.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:news_app/core/constants/api_constant.dart";
import "package:news_app/features/models/article_model.dart";

part "news_event.dart";
part "news_state.dart";

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final Dio _dio = Dio();
  
  NewsBloc() : super(NewsInitial()) {
    on<LoadTopHeadlines>(_onLoadTopHeadlines);
    on<LoadEverything>(_onLoadEverything);
    on<LoadMoreEverything>(_onLoadMoreEverything);
    on<SearchNews>(_onSearchNews);
    on<RefreshNews>(_onRefreshNews);
  }

  // Helper method to process articles
  List<Article> _processArticles(List<dynamic> articles) {
    return articles
        .map((json) => Article.fromJson(json))
        .where((article) => article.title != "[Removed]")
        .toList();
  }

  // 1. Top Headlines API Call
  Future<void> _onLoadTopHeadlines(LoadTopHeadlines event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    try {
      final response = await _dio.get(
        "${ApiConstants.baseUrl}${ApiConstants.topHeadlines}",
        queryParameters: {
          "apiKey": ApiConstants.apiKey,
          "q": "india",
        },
      );

      if (response.statusCode == 200) {
        final List articles = response.data["articles"];
        final processedArticles = _processArticles(articles);
        emit(NewsLoaded(processedArticles, newsType: "Top Headlines 🇮🇳"));
      } else {
        emit(NewsError("Failed to load top headlines"));
      }
    } catch (e) {
      log("Top Headlines Error: ${e.toString()}");
      emit(NewsError("Error loading top headlines: $e"));
    }
  }

  // 2. Everything API Call with Pagination Support
  Future<void> _onLoadEverything(LoadEverything event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    try {
      final response = await _dio.get(
        "${ApiConstants.baseUrl}${ApiConstants.everything}",
        queryParameters: {
          "apiKey": ApiConstants.apiKey,
          "q": "india",
          "pageSize": 100, // Fetch more articles for pagination
        },
      );

      if (response.statusCode == 200) {
        final List articles = response.data["articles"];
        final processedArticles = _processArticles(articles);
        emit(EverythingNewsLoaded(
          allArticles: processedArticles,
          displayedArticles: processedArticles.take(10).toList(), // Show first 10
          hasMoreData: processedArticles.length > 10,
        ));
      } else {
        emit(NewsError("Failed to load everything news"));
      }
    } catch (e) {
      log("Everything Error: ${e.toString()}");
      emit(NewsError("Error loading everything news: $e"));
    }
  }

  // 3. Load More Everything Articles
  Future<void> _onLoadMoreEverything(LoadMoreEverything event, Emitter<NewsState> emit) async {
    if (state is EverythingNewsLoaded) {
      final currentState = state as EverythingNewsLoaded;
      
      if (!currentState.hasMoreData || currentState.isLoadingMore) {
        return; // Don't load if no more data or already loading
      }

      // Emit loading more state
      emit(currentState.copyWith(isLoadingMore: true));

      // Simulate a small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      final currentDisplayedCount = currentState.displayedArticles.length;
      final nextBatch = currentState.allArticles
          .skip(currentDisplayedCount)
          .take(10)
          .toList();

      final updatedDisplayedArticles = [
        ...currentState.displayedArticles,
        ...nextBatch,
      ];

      emit(EverythingNewsLoaded(
        allArticles: currentState.allArticles,
        displayedArticles: updatedDisplayedArticles,
        hasMoreData: updatedDisplayedArticles.length < currentState.allArticles.length,
        isLoadingMore: false,
      ));
    }
  }

  // 4. Search News API Call
  Future<void> _onSearchNews(SearchNews event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    try {
      final response = await _dio.get(
        "${ApiConstants.baseUrl}${ApiConstants.everything}",
        queryParameters: {
          "apiKey": ApiConstants.apiKey,
          "q": event.query,
        },
      );

      if (response.statusCode == 200) {
        final List articles = response.data["articles"];
        final processedArticles = _processArticles(articles);
        emit(NewsLoaded(processedArticles, newsType: "Search: \"${event.query}\""));
      } else {
        emit(NewsError("Failed to search news"));
      }
    } catch (e) {
      log("Search Error: ${e.toString()}");
      emit(NewsError("Error searching news: $e"));
    }
  }

  // 5. Refresh News
  Future<void> _onRefreshNews(RefreshNews event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    try {
      final topHeadlinesResponse = await _dio.get(
        "${ApiConstants.baseUrl}${ApiConstants.topHeadlines}",
        queryParameters: {
          "apiKey": ApiConstants.apiKey,
          "q": "india",
        },
      );

      if (topHeadlinesResponse.statusCode == 200) {
        final List articles = topHeadlinesResponse.data["articles"];
        final processedArticles = _processArticles(articles);
        emit(NewsLoaded(processedArticles, newsType: "Top Headlines 🇮🇳"));
      }
    } catch (e) {
      emit(NewsError("Error refreshing top headlines: $e"));
      return;
    }

    try {
      final everythingResponse = await _dio.get(
        "${ApiConstants.baseUrl}${ApiConstants.everything}",
        queryParameters: {
          "apiKey": ApiConstants.apiKey,
          "q": "india",
          "pageSize": 100,
        },
      );

      if (everythingResponse.statusCode == 200) {
        final List articles = everythingResponse.data["articles"];
        final processedArticles = _processArticles(articles);
        emit(EverythingNewsLoaded(
          allArticles: processedArticles,
          displayedArticles: processedArticles.take(10).toList(),
          hasMoreData: processedArticles.length > 10,
        ));
      }
    } catch (e) {
      emit(NewsError("Error refreshing everything news: $e"));
    }
  }

  @override
  Future<void> close() {
    _dio.close();
    return super.close();
  }
}

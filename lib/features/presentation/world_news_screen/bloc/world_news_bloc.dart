import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/constants/api_constant.dart';
import 'package:news_app/features/models/article_model.dart';

part 'world_news_event.dart';
part 'world_news_state.dart';

class WorldNewsBloc extends Bloc<WorldNewsEvent, WorldNewsState> {
  final Dio _dio = Dio();

  WorldNewsBloc() : super(WorldNewsInitial()) {
    on<LoadWorldTopHeadlines>(_onLoadWorldTopHeadlines);
    on<LoadWorldEverything>(_onLoadWorldEverything);
    on<LoadMoreWorldEverything>(_onLoadMoreWorldEverything);
    on<SearchWorldNews>(_onSearchWorldNews);
    on<RefreshWorldNews>(_onRefreshWorldNews);
  }

  // Helper to process articles
  List<Article> _processArticles(List<dynamic> articles) {
    return articles
        .map((json) => Article.fromJson(json))
        .where((article) => article.title != "[Removed]")
        .toList();
  }

  Future<void> _onLoadWorldTopHeadlines(
      LoadWorldTopHeadlines event, Emitter<WorldNewsState> emit) async {
    emit(WorldNewsLoading());
    try {
      final response = await _dio.get(
        "${ApiConstants.baseUrl}${ApiConstants.topHeadlines}",
        queryParameters: {
          "apiKey": ApiConstants.apiKey,
          "language": "en",
        },
      );

      if (response.statusCode == 200) {
        final articles = _processArticles(response.data["articles"]);
        emit(WorldNewsLoaded(articles, newsType: "🌍 Top Headlines"));
      } else {
        emit(WorldNewsError("Failed to load world top headlines"));
      }
    } catch (e) {
      log("World Top Headlines Error: ${e.toString()}");
      emit(WorldNewsError("Error loading world top headlines: $e"));
    }
  }

  // Updated LoadWorldEverything with pagination support
  Future<void> _onLoadWorldEverything(
      LoadWorldEverything event, Emitter<WorldNewsState> emit) async {
    emit(WorldNewsLoading());
    try {
      final response = await _dio.get(
        "${ApiConstants.baseUrl}${ApiConstants.everything}",
        queryParameters: {
          "apiKey": ApiConstants.apiKey,
          "q": "world",
          "pageSize": 100, // Fetch more articles for pagination
        },
      );

      if (response.statusCode == 200) {
        final articles = _processArticles(response.data["articles"]);
        emit(WorldEverythingLoaded(
          allArticles: articles,
          displayedArticles: articles.take(10).toList(), // Show first 10
          hasMoreData: articles.length > 10,
        ));
      } else {
        emit(WorldNewsError("Failed to load world news"));
      }
    } catch (e) {
      log("World Everything Error: ${e.toString()}");
      emit(WorldNewsError("Error loading world everything: $e"));
    }
  }

  // New LoadMoreWorldEverything handler
  Future<void> _onLoadMoreWorldEverything(
      LoadMoreWorldEverything event, Emitter<WorldNewsState> emit) async {
    if (state is WorldEverythingLoaded) {
      final currentState = state as WorldEverythingLoaded;
      
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

      emit(WorldEverythingLoaded(
        allArticles: currentState.allArticles,
        displayedArticles: updatedDisplayedArticles,
        hasMoreData: updatedDisplayedArticles.length < currentState.allArticles.length,
        isLoadingMore: false,
      ));
    }
  }

  Future<void> _onSearchWorldNews(
      SearchWorldNews event, Emitter<WorldNewsState> emit) async {
    emit(WorldNewsLoading());
    try {
      final response = await _dio.get(
        "${ApiConstants.baseUrl}${ApiConstants.everything}",
        queryParameters: {
          "apiKey": ApiConstants.apiKey,
          "q": event.query,
          "language": "en",
        },
      );

      if (response.statusCode == 200) {
        final articles = _processArticles(response.data["articles"]);
        emit(WorldNewsLoaded(articles, newsType: 'Search: "${event.query}"'));
      } else {
        emit(WorldNewsError("Failed to search world news"));
      }
    } catch (e) {
      log("World Search Error: ${e.toString()}");
      emit(WorldNewsError("Error searching world news: $e"));
    }
  }

  // Updated Refresh handler
  Future<void> _onRefreshWorldNews(
      RefreshWorldNews event, Emitter<WorldNewsState> emit) async {
    emit(WorldNewsLoading());
    try {
      // Refresh Top Headlines
      final topHeadlinesResponse = await _dio.get(
        "${ApiConstants.baseUrl}${ApiConstants.topHeadlines}",
        queryParameters: {
          "apiKey": ApiConstants.apiKey,
          "language": "en",
        },
      );

      if (topHeadlinesResponse.statusCode == 200) {
        final articles = _processArticles(topHeadlinesResponse.data["articles"]);
        emit(WorldNewsLoaded(articles, newsType: "🌍 Top Headlines"));
      }
    } catch (e) {
      emit(WorldNewsError("Error refreshing world top headlines: $e"));
      return;
    }

    try {
      // Refresh Everything news
      final everythingResponse = await _dio.get(
        "${ApiConstants.baseUrl}${ApiConstants.everything}",
        queryParameters: {
          "apiKey": ApiConstants.apiKey,
          "q": "world",
          "pageSize": 100,
        },
      );

      if (everythingResponse.statusCode == 200) {
        final articles = _processArticles(everythingResponse.data["articles"]);
        emit(WorldEverythingLoaded(
          allArticles: articles,
          displayedArticles: articles.take(10).toList(),
          hasMoreData: articles.length > 10,
        ));
      }
    } catch (e) {
      emit(WorldNewsError("Error refreshing world everything: $e"));
    }
  }

  @override
  Future<void> close() {
    _dio.close();
    return super.close();
  }
}

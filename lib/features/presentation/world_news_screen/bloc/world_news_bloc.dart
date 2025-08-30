// lib/features/presentation/world_news_screen/bloc/world_news_bloc.dart
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/constants/api_constant.dart';
import 'package:news_app/core/mixin/connectivity_mixin.dart';
import 'package:news_app/features/models/article_model.dart';

part 'world_news_event.dart';
part 'world_news_state.dart';

class WorldNewsBloc extends Bloc<WorldNewsEvent, WorldNewsState>
    with ConnectivityMixin {
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
    LoadWorldTopHeadlines event,
    Emitter<WorldNewsState> emit,
  ) async {
    emit(WorldNewsLoading());

    final bool isConnected = await checkConnectivity();
    if (!isConnected) {
      emit(WorldNewsError(noInternetMessage));
      return;
    }

    try {
      final response = await _dio.get(
        "${ApiConstants.baseUrl}${ApiConstants.topHeadlines}",
        queryParameters: {"apiKey": ApiConstants.apiKey, "language": "en"},
      );

      if (response.statusCode == 200) {
        final articles = _processArticles(response.data["articles"]);
        emit(WorldNewsLoaded(articles, newsType: "🌍 Top Headlines"));
      } else {
        emit(WorldNewsError("Failed to load world top headlines"));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        emit(WorldNewsError(noInternetMessage));
      } else {
        emit(WorldNewsError("Error loading world top headlines: ${e.message}"));
      }
    } catch (e) {
      log("World Top Headlines Error: ${e.toString()}");
      emit(WorldNewsError("Error loading world top headlines: $e"));
    }
  }

  Future<void> _onLoadWorldEverything(
    LoadWorldEverything event,
    Emitter<WorldNewsState> emit,
  ) async {
    emit(WorldNewsLoading());

    final bool isConnected = await checkConnectivity();
    if (!isConnected) {
      emit(WorldNewsError(noInternetMessage));
      return;
    }

    try {
      final response = await _dio.get(
        "${ApiConstants.baseUrl}${ApiConstants.everything}",
        queryParameters: {
          "apiKey": ApiConstants.apiKey,
          "q": "world",
          "pageSize": 100,
        },
      );

      if (response.statusCode == 200) {
        final articles = _processArticles(response.data["articles"]);
        emit(
          WorldEverythingLoaded(
            allArticles: articles,
            displayedArticles: articles.take(10).toList(), // Show first 10
            hasMoreData: articles.length > 10,
          ),
        );
      } else {
        emit(WorldNewsError("Failed to load world news"));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        emit(WorldNewsError(noInternetMessage));
      } else {
        emit(WorldNewsError("Error loading world everything: ${e.message}"));
      }
    } catch (e) {
      log("World Everything Error: ${e.toString()}");
      emit(WorldNewsError("Error loading world everything: $e"));
    }
  }

  Future<void> _onLoadMoreWorldEverything(
    LoadMoreWorldEverything event,
    Emitter<WorldNewsState> emit,
  ) async {
    if (state is WorldEverythingLoaded) {
      final currentState = state as WorldEverythingLoaded;

      if (!currentState.hasMoreData || currentState.isLoadingMore) {
        return;
      }

      final bool isConnected = await checkConnectivity();
      if (!isConnected) {
        emit(WorldNewsError(noInternetMessage));
        return;
      }

      emit(currentState.copyWith(isLoadingMore: true));

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

      emit(
        WorldEverythingLoaded(
          allArticles: currentState.allArticles,
          displayedArticles: updatedDisplayedArticles,
          hasMoreData:
              updatedDisplayedArticles.length < currentState.allArticles.length,
          isLoadingMore: false,
        ),
      );
    }
  }

  Future<void> _onSearchWorldNews(
    SearchWorldNews event,
    Emitter<WorldNewsState> emit,
  ) async {
    emit(WorldNewsLoading());

    // Check connectivity first
    final bool isConnected = await checkConnectivity();
    if (!isConnected) {
      emit(WorldNewsError(noInternetMessage));
      return;
    }

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
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        emit(WorldNewsError(noInternetMessage));
      } else {
        emit(WorldNewsError("Error searching world news: ${e.message}"));
      }
    } catch (e) {
      log("World Search Error: ${e.toString()}");
      emit(WorldNewsError("Error searching world news: $e"));
    }
  }

  Future<void> _onRefreshWorldNews(
    RefreshWorldNews event,
    Emitter<WorldNewsState> emit,
  ) async {
    emit(WorldNewsLoading());

    final bool isConnected = await checkConnectivity();
    if (!isConnected) {
      emit(WorldNewsError(noInternetMessage));
      return;
    }

    try {
      // Refresh Top Headlines
      final topHeadlinesResponse = await _dio.get(
        "${ApiConstants.baseUrl}${ApiConstants.topHeadlines}",
        queryParameters: {"apiKey": ApiConstants.apiKey, "language": "en"},
      );

      if (topHeadlinesResponse.statusCode == 200) {
        final articles = _processArticles(
          topHeadlinesResponse.data["articles"],
        );
        emit(WorldNewsLoaded(articles, newsType: "🌍 Top Headlines"));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        emit(WorldNewsError(noInternetMessage));
      } else {
        emit(
          WorldNewsError("Error refreshing world top headlines: ${e.message}"),
        );
      }
      return;
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
        emit(
          WorldEverythingLoaded(
            allArticles: articles,
            displayedArticles: articles.take(10).toList(),
            hasMoreData: articles.length > 10,
          ),
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        emit(WorldNewsError(noInternetMessage));
      } else {
        emit(WorldNewsError("Error refreshing world everything: ${e.message}"));
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

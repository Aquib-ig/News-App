// lib/features/presentation/news_screen/bloc/news_bloc.dart
import "dart:developer";
import "package:dio/dio.dart";
import "package:equatable/equatable.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:news_app/core/constants/api_constant.dart";
import "package:news_app/core/mixin/connectivity_mixin.dart";
import "package:news_app/features/models/article_model.dart";

part "news_event.dart";
part "news_state.dart";

class NewsBloc extends Bloc<NewsEvent, NewsState> with ConnectivityMixin {
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

  Future<void> _onLoadTopHeadlines(LoadTopHeadlines event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    
    // Check connectivity
    final bool isConnected = await checkConnectivity();
    if (!isConnected) {
      emit(NewsError(noInternetMessage));
      return;
    }

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
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout) {
        emit(NewsError(noInternetMessage));
      } else {
        emit(NewsError("Error loading top headlines: ${e.message}"));
      }
    } catch (e) {
      log("Top Headlines Error: ${e.toString()}");
      emit(NewsError("Error loading top headlines: $e"));
    }
  }

  Future<void> _onLoadEverything(LoadEverything event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    
    final bool isConnected = await checkConnectivity();
    if (!isConnected) {
      emit(NewsError(noInternetMessage));
      return;
    }

    try {
      final response = await _dio.get(
        "${ApiConstants.baseUrl}${ApiConstants.everything}",
        queryParameters: {
          "apiKey": ApiConstants.apiKey,
          "q": "india",
          "pageSize": 100, 
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
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout) {
        emit(NewsError(noInternetMessage));
      } else {
        emit(NewsError("Error loading everything news: ${e.message}"));
      }
    } catch (e) {
      log("Everything Error: ${e.toString()}");
      emit(NewsError("Error loading everything news: $e"));
    }
  }

  Future<void> _onLoadMoreEverything(LoadMoreEverything event, Emitter<NewsState> emit) async {
    if (state is EverythingNewsLoaded) {
      final currentState = state as EverythingNewsLoaded;
      
      if (!currentState.hasMoreData || currentState.isLoadingMore) {
        return; // Don't load if no more data or already loading
      }

      // Check connectivity before loading more
      final bool isConnected = await checkConnectivity();
      if (!isConnected) {
        emit(NewsError(noInternetMessage));
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

      emit(EverythingNewsLoaded(
        allArticles: currentState.allArticles,
        displayedArticles: updatedDisplayedArticles,
        hasMoreData: updatedDisplayedArticles.length < currentState.allArticles.length,
        isLoadingMore: false,
      ));
    }
  }

  Future<void> _onSearchNews(SearchNews event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    
    final bool isConnected = await checkConnectivity();
    if (!isConnected) {
      emit(NewsError(noInternetMessage));
      return;
    }

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
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout) {
        emit(NewsError(noInternetMessage));
      } else {
        emit(NewsError("Error searching news: ${e.message}"));
      }
    } catch (e) {
      log("Search Error: ${e.toString()}");
      emit(NewsError("Error searching news: $e"));
    }
  }

  Future<void> _onRefreshNews(RefreshNews event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    
    // Check connectivity first
    final bool isConnected = await checkConnectivity();
    if (!isConnected) {
      emit(NewsError(noInternetMessage));
      return;
    }

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
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout) {
        emit(NewsError(noInternetMessage));
      } else {
        emit(NewsError("Error refreshing top headlines: ${e.message}"));
      }
      return;
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
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout) {
        emit(NewsError(noInternetMessage));
      } else {
        emit(NewsError("Error refreshing everything news: ${e.message}"));
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

// Create category_bloc.dart
import "dart:developer";
import "package:dio/dio.dart";
import "package:equatable/equatable.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:news_app/core/constants/api_constant.dart";
import "package:news_app/features/models/article_model.dart";

part "category_event.dart";
part "category_state.dart";

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final Dio _dio = Dio();
  
  CategoryBloc() : super(CategoryInitial()) {
    on<LoadCategoryNews>(_onLoadCategoryNews);
  }

  Future<void> _onLoadCategoryNews(LoadCategoryNews event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final response = await _dio.get(
        "${ApiConstants.baseUrl}${ApiConstants.everything}",
        queryParameters: {
          "apiKey": ApiConstants.apiKey,
          "q": "india+${event.category}",
        },
      );

      if (response.statusCode == 200) {
        final List articles = response.data["articles"];
        final processedArticles = articles
            .map((json) => Article.fromJson(json))
            .where((article) => article.title != "[Removed]")
            .toList();
        emit(CategoryLoaded(processedArticles, category: event.category));
      } else {
        emit(CategoryError("Failed to load category news"));
      }
    } catch (e) {
      log("Category Error: ${e.toString()}");
      emit(CategoryError("Error loading category news: $e"));
    }
  }

  @override
  Future<void> close() {
    _dio.close();
    return super.close();
  }
}

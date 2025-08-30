import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/features/models/article_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkCubit extends Cubit<List<Article>> {
  BookmarkCubit() : super([]) {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = prefs.getStringList('bookmarks') ?? [];
    final articles = bookmarksJson
        .map((json) => Article.fromJson(jsonDecode(json)))
        .toList();
    emit(articles);
  }

  Future<void> toggleBookmark(Article article) async {
    final currentState = List<Article>.from(state);
    final prefs = await SharedPreferences.getInstance();
    final isBookmarked = currentState.any((a) => a.title == article.title);

    if (isBookmarked) {
      currentState.removeWhere((a) => a.title == article.title);
    } else {
      currentState.add(article);
    }

    // Save to SharedPreferences
    final bookmarksJson =
        currentState.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList('bookmarks', bookmarksJson);

    emit(currentState);
  }

  bool isBookmarked(Article article) {
    return state.any((a) => a.title == article.title);
  }
}

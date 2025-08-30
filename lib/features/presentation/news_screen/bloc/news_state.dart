part of "news_bloc.dart";

sealed class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object> get props => [];
}

final class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<Article> articles;
  final String newsType;
  
  const NewsLoaded(this.articles, {required this.newsType});
  
  @override
  List<Object> get props => [articles, newsType];
}

// New state for paginated everything news
class EverythingNewsLoaded extends NewsState {
  final List<Article> allArticles;
  final List<Article> displayedArticles;
  final bool hasMoreData;
  final bool isLoadingMore;
  
  const EverythingNewsLoaded({
    required this.allArticles,
    required this.displayedArticles,
    required this.hasMoreData,
    this.isLoadingMore = false,
  });
  
  EverythingNewsLoaded copyWith({
    List<Article>? allArticles,
    List<Article>? displayedArticles,
    bool? hasMoreData,
    bool? isLoadingMore,
  }) {
    return EverythingNewsLoaded(
      allArticles: allArticles ?? this.allArticles,
      displayedArticles: displayedArticles ?? this.displayedArticles,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
  
  @override
  List<Object> get props => [allArticles, displayedArticles, hasMoreData, isLoadingMore];
}

class NewsError extends NewsState {
  final String message;
  const NewsError(this.message);
  
  @override
  List<Object> get props => [message];
}

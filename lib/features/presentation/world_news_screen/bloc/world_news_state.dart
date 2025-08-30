part of 'world_news_bloc.dart';

abstract class WorldNewsState extends Equatable {
  const WorldNewsState();

  @override
  List<Object?> get props => [];
}

/// Initial State
class WorldNewsInitial extends WorldNewsState {}

/// Loading State
class WorldNewsLoading extends WorldNewsState {}

/// Loaded State
class WorldNewsLoaded extends WorldNewsState {
  final List<Article> articles;
  final String newsType;

  const WorldNewsLoaded(this.articles, {required this.newsType});

  @override
  List<Object?> get props => [articles, newsType];
}

// New state for paginated everything news
class WorldEverythingLoaded extends WorldNewsState {
  final List<Article> allArticles;
  final List<Article> displayedArticles;
  final bool hasMoreData;
  final bool isLoadingMore;
  
  const WorldEverythingLoaded({
    required this.allArticles,
    required this.displayedArticles,
    required this.hasMoreData,
    this.isLoadingMore = false,
  });
  
  WorldEverythingLoaded copyWith({
    List<Article>? allArticles,
    List<Article>? displayedArticles,
    bool? hasMoreData,
    bool? isLoadingMore,
  }) {
    return WorldEverythingLoaded(
      allArticles: allArticles ?? this.allArticles,
      displayedArticles: displayedArticles ?? this.displayedArticles,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
  
  @override
  List<Object?> get props => [allArticles, displayedArticles, hasMoreData, isLoadingMore];
}

/// Error State
class WorldNewsError extends WorldNewsState {
  final String message;
  const WorldNewsError(this.message);

  @override
  List<Object?> get props => [message];
}

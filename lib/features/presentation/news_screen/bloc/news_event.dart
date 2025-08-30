part of "news_bloc.dart";

sealed class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTopHeadlines extends NewsEvent {}

class LoadEverything extends NewsEvent {}

class LoadMoreEverything extends NewsEvent {} // New event for pagination

class LoadCategoryNews extends NewsEvent {
  final String category;
  const LoadCategoryNews({required this.category});
  
  @override
  List<Object> get props => [category];
}

class SearchNews extends NewsEvent {
  final String query;
  const SearchNews({required this.query});
  
  @override
  List<Object> get props => [query];
}

class RefreshNews extends NewsEvent {}

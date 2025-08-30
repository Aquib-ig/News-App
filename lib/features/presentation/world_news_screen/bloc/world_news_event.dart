part of 'world_news_bloc.dart';

abstract class WorldNewsEvent extends Equatable {
  const WorldNewsEvent();

  @override
  List<Object?> get props => [];
}

/// Load Top Headlines for World
class LoadWorldTopHeadlines extends WorldNewsEvent {}

/// Load Everything (all world news)
class LoadWorldEverything extends WorldNewsEvent {}

/// Load More Everything - New event for pagination
class LoadMoreWorldEverything extends WorldNewsEvent {}

/// Search World News
class SearchWorldNews extends WorldNewsEvent {
  final String query;
  const SearchWorldNews({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Refresh News
class RefreshWorldNews extends WorldNewsEvent {}

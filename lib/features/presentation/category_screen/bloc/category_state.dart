// category_state.dart
part of "category_bloc.dart";

sealed class CategoryState extends Equatable {
  const CategoryState();
  @override
  List<Object> get props => [];
}

final class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Article> articles;
  final String category;
  
  const CategoryLoaded(this.articles, {required this.category});
  
  @override
  List<Object> get props => [articles, category];
}

class CategoryError extends CategoryState {
  final String message;
  const CategoryError(this.message);
  
  @override
  List<Object> get props => [message];
}

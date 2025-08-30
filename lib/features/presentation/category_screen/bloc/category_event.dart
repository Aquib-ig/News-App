// category_event.dart
part of "category_bloc.dart";

sealed class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object> get props => [];
}

class LoadCategoryNews extends CategoryEvent {
  final String category;
  const LoadCategoryNews({required this.category});
  
  @override
  List<Object> get props => [category];
}

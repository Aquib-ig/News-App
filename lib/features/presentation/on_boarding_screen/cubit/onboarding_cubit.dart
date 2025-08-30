import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingCubit extends Cubit<int> {
  OnboardingCubit() : super(0);

  void setPage(int index) => emit(index);

  bool get isFirstPage => state == 0;
  bool get isSecondPage => state == 1;
  bool get isLastPage => state == 2;
}

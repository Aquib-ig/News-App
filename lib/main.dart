import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:news_app/core/themes/app_theme.dart';
import 'package:news_app/features/presentation/app_screen/bottom_nav_bar.dart';
import 'package:news_app/features/presentation/on_boarding_screen/onboarding_screen.dart';
import 'package:news_app/features/presentation/setting_screen/cubit/theme_cubit.dart';
import 'package:news_app/features/presentation/app_screen/cubit/bottom_nav_cubit.dart';
import 'package:news_app/features/presentation/bookmark_screen/cubit/bookmark_cubit.dart';
import 'package:news_app/features/presentation/category_screen/bloc/category_bloc.dart';
import 'package:news_app/features/presentation/news_screen/bloc/news_bloc.dart';
import 'package:news_app/features/presentation/world_news_screen/bloc/world_news_bloc.dart';
import 'package:news_app/features/presentation/app_screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BottomNavCubit()),
        BlocProvider(create: (_) => BookmarkCubit()),
        BlocProvider(create: (_) => NewsBloc()),
        BlocProvider(create: (_) => WorldNewsBloc()),
        BlocProvider(create: (_) => CategoryBloc()),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          title: 'News App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}

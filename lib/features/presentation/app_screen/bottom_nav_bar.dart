import 'package:easy_animated_indexed_stack/easy_animated_indexed_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:news_app/core/constants/app_icons.dart';
import 'package:news_app/core/themes/app_colors.dart';
import 'package:news_app/features/presentation/app_screen/cubit/bottom_nav_cubit.dart';
import 'package:news_app/features/presentation/bookmark_screen/bookmark_screen.dart';
import 'package:news_app/features/presentation/news_screen/news_screen.dart';
import 'package:news_app/features/presentation/setting_screen/setting_screen.dart';
import 'package:news_app/features/presentation/world_news_screen/world_news_screen.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  final List<String> _icons = const [
    AppIcons.homeIcon,
    AppIcons.worldIcon,
    AppIcons.bookMarkIcon,
    AppIcons.settingIcon,
  ];

  final List<Widget> _screens = const [
    NewsScreen(),
    WorldNewsScreen(),
    SavedArticlesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bottomNavColor = isDarkMode
        ? AppColors.darkBottomNav
        : AppColors.lightBottomNav;
    final activeColor = isDarkMode
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;
    final inactiveColor = isDarkMode
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return BlocBuilder<BottomNavCubit, int>(
      builder: (context, selectedIndex) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: isDarkMode
              ? AppColors.darkBackground
              : AppColors.lightSurface,
          body: Stack(
            children: [
              // Screens with Smooth Transition
              Positioned.fill(
                child: EasyAnimatedIndexedStack(
                  index: selectedIndex,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  children: _screens,
                ),
              ),

              // Enhanced Floating Bottom Navigation Bar
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                  decoration: BoxDecoration(
                    color: bottomNavColor,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.black.withOpacity(0.4)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: isDarkMode ? 20 : 15,
                        offset: const Offset(0, 6),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: List.generate(_icons.length, (index) {
                      final isActive = selectedIndex == index;
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () =>
                              context.read<BottomNavCubit>().setIndex(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Animated Icon with Scale Effect
                                AnimatedScale(
                                  scale: isActive ? 1.1 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: isActive
                                        ? BoxDecoration(
                                            color: activeColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          )
                                        : null,
                                    child: SvgPicture.asset(
                                      _icons[index],
                                      width: 24,
                                      height: 24,
                                      color: isActive
                                          ? activeColor
                                          : inactiveColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Animated Indicator Dot
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  height: 4,
                                  width: isActive ? 24 : 0,
                                  decoration: BoxDecoration(
                                    color: activeColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

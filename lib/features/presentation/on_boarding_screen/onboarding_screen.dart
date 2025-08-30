import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/core/themes/app_colors.dart';
import 'package:news_app/features/presentation/app_screen/bottom_nav_bar.dart';
import 'package:news_app/features/presentation/on_boarding_screen/cubit/onboarding_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  Future<void>? _buttonFuture;

  Future<void> _completeOnboarding() async {
    // Save onboarding completion
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const BottomNavBar()),
      (route) => false,
    );
  }

  Widget _buildPage(String title, String description) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        body: SafeArea(
          child: BlocBuilder<OnboardingCubit, int>(
            builder: (context, pageIndex) {
              final cubit = context.read<OnboardingCubit>();

              return Column(
                children: [
                  // Pages
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: cubit.setPage,
                      children: [
                        _buildPage(
                          "🇮🇳 India News",
                          "Stay updated with the latest news and events from India. Get comprehensive coverage of politics, sports, entertainment, and more from across the nation.",
                        ),
                        _buildPage(
                          "🌍 World News",
                          "Keep track of global events and international stories. Stay informed about what's happening around the world with breaking news updates.",
                        ),
                        _buildPage(
                          "📂 Categories",
                          "Explore news by categories tailored to your interests. From business to technology, sports to entertainment - find what matters to you most.",
                        ),
                      ],
                    ),
                  ),

                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 3,
                    effect: WormEffect(
                      activeDotColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                      dotColor: isDark
                          ? AppColors.darkTextSecondary.withOpacity(0.3)
                          : AppColors.lightTextSecondary.withOpacity(0.3),
                      dotHeight: 12,
                      dotWidth: 12,
                      spacing: 12,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Buttons with FutureBuilder
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: cubit.isLastPage
                        ? FutureBuilder<void>(
                            future: _buttonFuture,
                            builder: (context, snapshot) {
                              final isLoading =
                                  snapshot.connectionState ==
                                  ConnectionState.waiting;

                              return SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          setState(() {
                                            _buttonFuture =
                                                _completeOnboarding();
                                          });
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark
                                        ? AppColors.darkPrimary
                                        : AppColors.lightPrimary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: isLoading
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Text(
                                          "Let's Get Started",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              );
                            },
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Previous/Skip/Next buttons (unchanged)
                              if (cubit.isFirstPage)
                                TextButton(
                                  onPressed: () =>
                                      _pageController.jumpToPage(2),
                                  child: const Text("Skip"),
                                )
                              else if (cubit.isSecondPage)
                                TextButton(
                                  onPressed: () => _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  ),
                                  child: const Text("Previous"),
                                )
                              else
                                const SizedBox(width: 80),

                              TextButton(
                                onPressed: () => _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                ),
                                child: const Text("Next"),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

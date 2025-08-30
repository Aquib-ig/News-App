import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/svg.dart";
import "package:news_app/core/constants/api_constant.dart";
import "package:news_app/core/constants/app_icons.dart";
import "package:news_app/core/themes/app_colors.dart";
import "package:news_app/features/presentation/news_screen/bloc/news_bloc.dart";
import "package:news_app/features/widgets/article_card.dart";
import "package:news_app/features/widgets/carousel_card.dart";
import "package:news_app/features/widgets/category_widget.dart";
import "package:news_app/features/widgets/custom_text_field.dart";

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<NewsBloc>().add(LoadTopHeadlines());
    context.read<NewsBloc>().add(LoadEverything());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NewsBloc>().add(LoadMoreEverything());
    }
  }

  Future<void> _onRefresh() async {
    context.read<NewsBloc>().add(RefreshNews());
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 140,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "🇮🇳 Today's Indian Headlines",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    // Handle notification tap
                  },
                  child: SvgPicture.asset(
                    AppIcons.notification,
                    height: 24,
                    width: 24,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: "Search news...",
              controller: _searchController,
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  context.read<NewsBloc>().add(SearchNews(query: query));
                }
              },
            ),
          ],
        ),
      ),

      body: RefreshIndicator(
        displacement: 40.0,
        edgeOffset: 0.0,
        onRefresh: _onRefresh,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add some top padding for better visibility
                const SizedBox(height: 16),

                // Categories Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.category,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Categories",
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CategoryWidget(
                  categories: ApiConstants.categories,
                  categoryNames: ApiConstants.categoryNames,
                ),

                const SizedBox(height: 24),

                // Top Headlines Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Top Headlines",
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                BlocBuilder<NewsBloc, NewsState>(
                  buildWhen: (previous, current) {
                    if (current is NewsLoading) {
                      return previous is NewsInitial ||
                          (previous is NewsLoaded &&
                              previous.newsType.contains("Top Headlines"));
                    }
                    if (current is NewsLoaded &&
                        current.newsType.contains("Top Headlines")) {
                      return true;
                    }
                    if (current is NewsError) return true;
                    return false;
                  },
                  builder: (context, state) {
                    if (state is NewsLoading) {
                      return CarouselCard(articles: const [], isLoading: true);
                    }

                    if (state is NewsLoaded &&
                        state.newsType.contains("Top Headlines")) {
                      return CarouselCard(
                        articles: state.articles,
                        isLoading: false,
                      );
                    }

                    if (state is NewsError) {
                      return CarouselCard(
                        articles: const [],
                        isLoading: false,
                        errorMessage: state.message,
                      );
                    }

                    return CarouselCard(articles: const [], isLoading: false);
                  },
                ),
                const SizedBox(height: 24),

                // Latest News Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        "🇮🇳 Latest News",
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                BlocBuilder<NewsBloc, NewsState>(
                  buildWhen: (previous, current) {
                    return current is NewsLoading ||
                        current is NewsError ||
                        current is EverythingNewsLoaded;
                  },
                  builder: (context, state) {
                    if (state is NewsLoading &&
                        (state is! EverythingNewsLoaded)) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (state is NewsError) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              "Error: ${state.message}",
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                context.read<NewsBloc>().add(LoadEverything());
                              },
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is EverythingNewsLoaded) {
                      if (state.displayedArticles.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("No news available"),
                        );
                      }

                      return Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.displayedArticles.length,
                            itemBuilder: (context, index) {
                              return ArticleCard(
                                article: state.displayedArticles[index],
                              );
                            },
                          ),

                          if (state.isLoadingMore)
                            Container(
                              padding: const EdgeInsets.all(20.0),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(strokeWidth: 2),
                                  SizedBox(width: 12),
                                  Text("Loading more articles..."),
                                ],
                              ),
                            ),

                          // End of articles message
                          if (!state.hasMoreData &&
                              state.displayedArticles.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(20.0),
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 32,
                                    color: Colors.green,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "You've reached the end!",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "No more articles to load",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Bottom spacing for floating nav bar
                          const SizedBox(height: 100),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

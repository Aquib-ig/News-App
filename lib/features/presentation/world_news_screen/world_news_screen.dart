import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/svg.dart";
import "package:news_app/core/themes/app_colors.dart";
import "package:news_app/features/presentation/world_news_screen/bloc/world_news_bloc.dart";
import "package:news_app/features/widgets/article_card.dart";
import "package:news_app/features/widgets/carousel_card.dart";
import "package:news_app/features/widgets/custom_text_field.dart";

class WorldNewsScreen extends StatefulWidget {
  const WorldNewsScreen({super.key});

  @override
  State<WorldNewsScreen> createState() => _WorldNewsScreenState();
}

class _WorldNewsScreenState extends State<WorldNewsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<WorldNewsBloc>().add(LoadWorldTopHeadlines());
    context.read<WorldNewsBloc>().add(LoadWorldEverything());
    
    // Add scroll listener for pagination
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
      // Load more when near bottom
      context.read<WorldNewsBloc>().add(LoadMoreWorldEverything());
    }
  }

  Future<void> _onRefresh() async {
    context.read<WorldNewsBloc>().add(RefreshWorldNews());
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
                    "🌍 World Headlines",
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
                    "assets/icons/notification.svg",
                    height: 24,
                    width: 24,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: "Search world news...",
              controller: _searchController,
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  context.read<WorldNewsBloc>().add(SearchWorldNews(query: query));
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
                
                // Top Headlines Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.public,
                        color: AppColors.lightPrimary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "World Top Headlines",
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Carousel with BLoC Logic for Top Headlines
                BlocBuilder<WorldNewsBloc, WorldNewsState>(
                  buildWhen: (previous, current) {
                    if (current is WorldNewsLoading) {
                      return previous is WorldNewsInitial ||
                             (previous is WorldNewsLoaded && 
                              previous.newsType.contains("Top Headlines"));
                    }
                    if (current is WorldNewsLoaded &&
                        current.newsType.contains("Top Headlines")) {
                      return true;
                    }
                    if (current is WorldNewsError) return true;
                    return false;
                  },
                  builder: (context, state) {
                    if (state is WorldNewsLoading) {
                      return CarouselCard(
                        articles: const [],
                        isLoading: true,
                      );
                    }
                    
                    if (state is WorldNewsLoaded && 
                        state.newsType.contains("Top Headlines")) {
                      return CarouselCard(
                        articles: state.articles,
                        isLoading: false,
                      );
                    }
                    
                    if (state is WorldNewsError) {
                      return CarouselCard(
                        articles: const [],
                        isLoading: false,
                        errorMessage: state.message,
                      );
                    }
                    
                    return CarouselCard(
                      articles: const [],
                      isLoading: false,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Latest World News Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        "🌍 Latest World News",
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Latest World News List with Pagination
                BlocBuilder<WorldNewsBloc, WorldNewsState>(
                  buildWhen: (previous, current) {
                    return current is WorldNewsLoading ||
                           current is WorldNewsError ||
                           current is WorldEverythingLoaded;
                  },
                  builder: (context, state) {
                    if (state is WorldNewsLoading && 
                        (state is! WorldEverythingLoaded)) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (state is WorldNewsError) {
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
                                context.read<WorldNewsBloc>().add(LoadWorldEverything());
                              },
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is WorldEverythingLoaded) {
                      if (state.displayedArticles.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("No world news available"),
                        );
                      }

                      return Column(
                        children: [
                          // Articles List
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
                          
                          // Loading More Indicator
                          if (state.isLoadingMore)
                            Container(
                              padding: const EdgeInsets.all(20.0),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(strokeWidth: 2),
                                  SizedBox(width: 12),
                                  Text("Loading more world news..."),
                                ],
                              ),
                            ),
                          
                          // Load More Button (optional)
                          if (state.hasMoreData && 
                              !state.isLoadingMore && 
                              state.displayedArticles.length >= 10)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    context.read<WorldNewsBloc>().add(LoadMoreWorldEverything());
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text("Load More Articles"),
                                ),
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
                                    "No more world news to load",
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

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:news_app/core/themes/app_colors.dart";
import "package:news_app/features/models/article_model.dart";
import "package:news_app/features/presentation/bookmark_screen/cubit/bookmark_cubit.dart";
import "package:news_app/features/widgets/saved_article_card.dart";

class SavedArticlesScreen extends StatelessWidget {
  const SavedArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Saved Articles",
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: BlocBuilder<BookmarkCubit, List<Article>>(
        builder: (context, bookmarkedArticles) {
          if (bookmarkedArticles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No saved articles",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Articles you bookmark will appear here",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with count
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "${bookmarkedArticles.length} saved article${bookmarkedArticles.length != 1 ? 's' : ''}",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.lightPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Articles List
              Expanded(
                child: ListView.builder(
                  itemCount: bookmarkedArticles.length,
                  itemBuilder: (context, index) {
                    final article = bookmarkedArticles[index];
                    return SavedArticleCard(article: article);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

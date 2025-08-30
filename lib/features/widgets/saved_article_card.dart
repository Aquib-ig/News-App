import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:news_app/core/constants/app_icons.dart";
import "package:news_app/core/themes/app_colors.dart";
import "package:news_app/core/utils/navigation_ustils.dart";
import "package:news_app/features/models/article_model.dart";
import "package:news_app/features/presentation/bookmark_screen/cubit/bookmark_cubit.dart";
import "package:news_app/features/presentation/news_screen/article_detail_screen.dart";

class SavedArticleCard extends StatelessWidget {
  final Article article;

  const SavedArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          NavigationUtils.navigateWithSlide(
            context,
            ArticleDetailScreen(article: article),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child:
                      article.urlToImage != null &&
                          article.urlToImage!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: article.urlToImage!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.lightPrimary.withOpacity(0.1),
                            child: Icon(
                              Icons.image_not_supported,
                              color: AppColors.lightPrimary,
                              size: 32,
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.lightPrimary.withOpacity(0.1),
                          child: Icon(
                            Icons.article,
                            color: AppColors.lightPrimary,
                            size: 32,
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 12),

              // Content Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author
                    if (article.author != null && article.author!.isNotEmpty)
                      Text(
                        "By ${article.author!}",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.lightPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        article.sourceName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.lightPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 4),

                    // Title/Summary
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Description if available
                    if (article.description != null &&
                        article.description!.isNotEmpty)
                      Text(
                        article.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Remove Bookmark Button
              GestureDetector(
                onTap: () {
                  context.read<BookmarkCubit>().toggleBookmark(article);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        "Article removed from saved articles",
                      ),
                      duration: const Duration(seconds: 1),
                      backgroundColor: Colors.red[600],
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    AppIcons.bookmarkIcon,
                    width: 18,
                    height: 18,
                    color: AppColors.lightPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

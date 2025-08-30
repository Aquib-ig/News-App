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

class ArticleCard extends StatelessWidget {
  final Article article;
  final double imageHeight;
  final bool showDescription;

  const ArticleCard({
    super.key,
    required this.article,
    this.imageHeight = 200,
    this.showDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            NavigationUtils.navigateWithFade(
              context,
              ArticleDetailScreen(article: article),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section with bookmark button
              if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: article.urlToImage!,
                        height: imageHeight,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: imageHeight,
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: imageHeight,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 64,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: BlocBuilder<BookmarkCubit, List<Article>>(
                        builder: (context, bookmarks) {
                          final isBookmarked = bookmarks.any(
                            (a) => a.title == article.title,
                          );
                          return GestureDetector(
                            onTap: () {
                              context.read<BookmarkCubit>().toggleBookmark(
                                article,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isBookmarked
                                        ? "Article removed from saved articles"
                                        : "Article added to saved articles",
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: isBookmarked
                                      ? Colors.red[600]
                                      : AppColors.lightPrimary,
                                ),
                              );
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  isBookmarked
                                      ? AppIcons.bookmarkIcon
                                      : AppIcons.bookmarkOutlineIcon,
                                  width: 20,
                                  height: 20,
                                  color: isBookmarked
                                      ? AppColors.lightPrimary
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              else
                Stack(
                  children: [
                    Container(
                      height: imageHeight,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.lightPrimary.withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Icon(
                        Icons.article,
                        size: 64,
                        color: AppColors.lightPrimary,
                      ),
                    ),
                    // Bookmark button for placeholder
                    Positioned(
                      top: 12,
                      right: 12,
                      child: BlocBuilder<BookmarkCubit, List<Article>>(
                        builder: (context, bookmarks) {
                          final isBookmarked = bookmarks.any(
                            (a) => a.title == article.title,
                          );
                          return GestureDetector(
                            onTap: () {
                              context.read<BookmarkCubit>().toggleBookmark(
                                article,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isBookmarked
                                        ? "Article removed from saved articles"
                                        : "Article added to saved articles",
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: isBookmarked
                                      ? Colors.red[600]
                                      : AppColors.lightPrimary,
                                ),
                              );
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  isBookmarked
                                      ? AppIcons.bookmarkIcon
                                      : AppIcons.bookmarkOutlineIcon,
                                  width: 20,
                                  height: 20,
                                  color: isBookmarked
                                      ? AppColors.lightPrimary
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

              // Content section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (showDescription &&
                        article.description != null &&
                        article.description!.isNotEmpty)
                      Text(
                        article.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            article.sourceName,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.lightPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(article.publishedAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays > 0) return "${diff.inDays}d ago";
      if (diff.inHours > 0) return "${diff.inHours}h ago";
      return "${diff.inMinutes}m ago";
    } catch (_) {
      return "Unknown";
    }
  }
}

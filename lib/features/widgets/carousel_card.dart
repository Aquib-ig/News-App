import "package:cached_network_image/cached_network_image.dart";
import "package:carousel_slider/carousel_slider.dart";
import "package:flutter/material.dart";
import "package:news_app/core/themes/app_colors.dart";
import "package:news_app/core/utils/navigation_ustils.dart";
import "package:news_app/features/models/article_model.dart";
import "package:news_app/features/presentation/news_screen/article_detail_screen.dart";

class CarouselCard extends StatelessWidget {
  final List<Article> articles;
  final bool isLoading;
  final String? errorMessage;
  final double height;
  final Duration autoPlayInterval;

  const CarouselCard({
    super.key,
    required this.articles,
    this.isLoading = false,
    this.errorMessage,
    this.height = 240,
    this.autoPlayInterval = const Duration(seconds: 4),
  });

  @override
  Widget build(BuildContext context) {
    // Handle loading state
    if (isLoading) {
      return SizedBox(
        height: height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // Handle error state
    if (errorMessage != null) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            "Error: $errorMessage",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    // Handle empty articles
    if (articles.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text("No articles available")),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: height,
        aspectRatio: 16 / 9,
        viewportFraction: 0.80,
        enableInfiniteScroll: true,
        autoPlay: true,
        autoPlayInterval: autoPlayInterval,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        enlargeFactor: 0.1,
      ),
      items: articles.map((article) {
        return GestureDetector(
          onTap: () {
            NavigationUtils.navigateWithFade(
              context,
              ArticleDetailScreen(article: article),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (article.urlToImage != null &&
                      article.urlToImage!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: article.urlToImage!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 64),
                      ),
                    )
                  else
                    Container(
                      color: AppColors.lightPrimary.withOpacity(0.1),
                      child: Icon(
                        Icons.article,
                        size: 64,
                        color: AppColors.lightPrimary,
                      ),
                    ),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                article.sourceName,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              _formatDate(article.publishedAt),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
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
      }).toList(),
    );
  }

  static String _formatDate(String dateString) {
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

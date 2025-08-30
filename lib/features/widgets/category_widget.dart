import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:news_app/core/constants/app_icons.dart";
import "package:news_app/core/themes/app_colors.dart";
import "package:news_app/core/utils/navigation_ustils.dart";
import "package:news_app/features/presentation/category_screen/category_screen.dart";

class CategoryWidget extends StatelessWidget {
  final List<String> categories;
  final Map<String, String> categoryNames;
  final Function(String)? onCategoryTap;

  const CategoryWidget({
    super.key,
    required this.categories,
    required this.categoryNames,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final categoryName = categoryNames[category] ?? category;

          return GestureDetector(
            onTap: () {
              NavigationUtils.navigateWithSlide(
                context,
                CategoryScreen(category: category, categoryName: categoryName),
              );
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 22),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: AppColors.lightPrimary.withOpacity(0.1),
                    child: SvgPicture.asset(
                      _getCategoryIconPath(category),
                      width: 28,
                      height: 28,
                      color: AppColors.lightPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    categoryName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getCategoryIconPath(String category) {
    switch (category) {
      case "general":
        return AppIcons.general;
      case "business":
        return AppIcons.business;
      case "entertainment":
        return AppIcons.entertainment;
      case "health":
        return AppIcons.health;
      case "science":
        return AppIcons.science;
      case "sports":
        return AppIcons.sport;
      case "technology":
        return AppIcons.technology;
      default:
        return AppIcons.general;
    }
  }
}

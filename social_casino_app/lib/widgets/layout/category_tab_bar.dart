import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme/app_colors.dart';

class CategoryTabItem {
  final String slug;
  final String name;
  final IconData icon;
  final String route;
  final bool disabled;

  const CategoryTabItem({
    required this.slug,
    required this.name,
    required this.icon,
    required this.route,
    this.disabled = false,
  });
}

class CategoryTabBar extends StatelessWidget {
  const CategoryTabBar({super.key});

  // Game categories matching web app layout
  static const List<CategoryTabItem> categories = [
    CategoryTabItem(slug: 'my-casino', name: 'My Casino', icon: Icons.favorite, route: '/'),
    CategoryTabItem(slug: 'slots', name: 'Slots', icon: Icons.auto_awesome, route: '/category/slots'),
    CategoryTabItem(slug: 'live-casino', name: 'Live Casino', icon: Icons.videocam, route: '/category/live-casino'),
    CategoryTabItem(slug: 'table-games', name: 'Table Games', icon: Icons.grid_view, route: '/category/table-games'),
    CategoryTabItem(slug: 'instant-win', name: 'Instant Win', icon: Icons.flash_on, route: '/category/instant-win', disabled: true),
  ];

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: AppColors.casinoBgSecondary,
        border: Border(
          bottom: BorderSide(
            color: AppColors.casinoPurpleDark,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _isSelected(currentPath, category);

          return GestureDetector(
            onTap: category.disabled
                ? null
                : () => context.go(category.route),
            child: Opacity(
              opacity: category.disabled ? 0.5 : 1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.center,
                child: isSelected
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.casinoGold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category.icon,
                              color: Colors.black,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              category.name,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category.icon,
                              color: AppColors.textSecondary,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              category.name,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSelected(String currentPath, CategoryTabItem category) {
    if (category.route == '/') {
      // My Casino is selected when on root or no category path
      return currentPath == '/' || currentPath.isEmpty;
    }
    return currentPath == category.route;
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme/app_colors.dart';

class CategoryTabItem {
  final String slug;
  final String name;
  final IconData icon;
  final String route;
  final bool disabled;
  final bool isNew;
  final bool isHot;

  const CategoryTabItem({
    required this.slug,
    required this.name,
    required this.icon,
    required this.route,
    this.disabled = false,
    this.isNew = false,
    this.isHot = false,
  });
}

class CategoryTabBar extends StatelessWidget {
  const CategoryTabBar({super.key});

  // Game categories - matching web app
  static const List<CategoryTabItem> categories = [
    CategoryTabItem(
      slug: 'my-casino',
      name: 'My Casino',
      icon: Icons.favorite_border,
      route: '/',
    ),
    CategoryTabItem(
      slug: 'slots',
      name: 'Slots',
      icon: Icons.auto_awesome,
      route: '/category/slots',
    ),
    CategoryTabItem(
      slug: 'live-casino',
      name: 'Live Casino',
      icon: Icons.videocam_outlined,
      route: '/category/live-casino',
    ),
    CategoryTabItem(
      slug: 'table-games',
      name: 'Table Games',
      icon: Icons.casino_outlined,
      route: '/category/table-games',
    ),
    CategoryTabItem(
      slug: 'instant-win',
      name: 'Instant Win',
      icon: Icons.bolt_outlined,
      route: '/category/instant-win',
      disabled: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

    return Container(
      height: 44,
      color: AppColors.casinoBg,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _isSelected(currentPath, category);

          return _CategoryPill(
            category: category,
            isSelected: isSelected,
            onTap: category.disabled
                ? null
                : () => context.go(category.route),
          );
        },
      ),
    );
  }

  bool _isSelected(String currentPath, CategoryTabItem category) {
    if (category.route == '/') {
      return currentPath == '/' || currentPath.isEmpty;
    }
    return currentPath == category.route;
  }
}

class _CategoryPill extends StatelessWidget {
  final CategoryTabItem category;
  final bool isSelected;
  final VoidCallback? onTap;

  const _CategoryPill({
    required this.category,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pillBgActive
              : AppColors.pillBg,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: AppColors.casinoGold.withValues(alpha: 0.3), width: 1)
              : null,
        ),
        child: Opacity(
          opacity: category.disabled ? 0.5 : 1.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with special styling for new/hot items
              if (category.isNew)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientGold,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category.icon,
                    color: Colors.black,
                    size: 12,
                  ),
                )
              else if (category.isHot)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      category.icon,
                      color: isSelected
                          ? AppColors.casinoGold
                          : AppColors.textSecondary,
                      size: 18,
                    ),
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.casinoRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Icon(
                  category.icon,
                  color: isSelected
                      ? AppColors.casinoGold
                      : AppColors.textSecondary,
                  size: 18,
                ),
              const SizedBox(width: 8),
              Text(
                category.name,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

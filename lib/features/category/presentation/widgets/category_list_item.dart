import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:template/features/category/domain/entities/category.dart';

class CategoryListItem extends StatelessWidget {
  const CategoryListItem({
    required this.category,
    this.onTap,
    this.onEdit,
    super.key,
  });

  final Category category;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final categoryName = category.name.getOrCrash();
    final typeData = _getCategoryTypeData(categoryName);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F5), // surface-container-low
          borderRadius: BorderRadius.circular(100),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: -10,
              right: -10,
              child: Opacity(
                opacity: 0.05,
                child: Icon(
                  typeData.icon,
                  size: 80,
                  color: typeData.primaryColor,
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: typeData.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    typeData.icon,
                    color: typeData.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: Alignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00113A), // primary
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: typeData.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            typeData.label.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2,
                              color: const Color(0xFF757682), // outline
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    color: const Color(0xFF757682),
                    onPressed: onEdit,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _CategoryTypeData _getCategoryTypeData(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('shop')) {
      return const _CategoryTypeData(
        icon: Icons.shopping_bag_outlined,
        label: 'Lifestyle',
        primaryColor: Color(0xFF00113A),
      );
    } else if (lowerName.contains('din') || lowerName.contains('food')) {
      return const _CategoryTypeData(
        icon: Icons.restaurant_outlined,
        label: 'Essential',
        primaryColor: Color(0xFF1B6D24),
      );
    } else if (lowerName.contains('hous') || lowerName.contains('home')) {
      return const _CategoryTypeData(
        icon: Icons.home_outlined,
        label: 'Fixed Cost',
        primaryColor: Color(0xFFBA1A1A),
      );
    } else if (lowerName.contains('trans') || lowerName.contains('car')) {
      return const _CategoryTypeData(
        icon: Icons.directions_car_outlined,
        label: 'Utility',
        primaryColor: Color(0xFF002366),
      );
    } else if (lowerName.contains('health')) {
      return const _CategoryTypeData(
        icon: Icons.monitor_heart_outlined,
        label: 'Wellness',
        primaryColor: Color(0xFFBA1A1A),
      );
    }
    // Default
    return const _CategoryTypeData(
      icon: Icons.category_outlined,
      label: 'Other',
      primaryColor: Color(0xFF00113A),
    );
  }
}

class _CategoryTypeData {
  const _CategoryTypeData({
    required this.icon,
    required this.label,
    required this.primaryColor,
  });

  final IconData icon;
  final String label;
  final Color primaryColor;
}

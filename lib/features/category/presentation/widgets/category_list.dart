import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_cubit.dart';
import 'package:expense_tracker/features/category/presentation/widgets/category_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({
    required this.categories,
    required this.onCategoryTap,
    required this.onAddTap,
    this.onEditTap,
    super.key,
  });

  final List<Category> categories;
  final void Function(Category) onCategoryTap;
  final VoidCallback onAddTap;
  final void Function(Category)? onEditTap;

  @override
  Widget build(BuildContext context) {
    final allCategories = context.read<CategoryCubit>().state.allCategories;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 600
                ? 2
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            mainAxisExtent: 140, // Height to fit the list item content
          ),
          itemCount: categories.length + 1,
          itemBuilder: (context, index) {
            if (index < categories.length) {
              final category = categories[index];
              final childCount = allCategories
                  .where(
                    (c) =>
                        c.parentId?.getOrCrash() == category.uuid.getOrCrash(),
                  )
                  .length;
              return CategoryListItem(
                category: category,
                childCount: childCount,
                onTap: () => onCategoryTap(category),
                onEdit: onEditTap != null ? () => onEditTap!(category) : null,
              );
            } else {
              return _NewCategoryCard(onTap: onAddTap);
            }
          },
        );
      },
    );
  }
}

class _NewCategoryCard extends StatelessWidget {
  const _NewCategoryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: const Color(0xFF757682).withValues(alpha: 0.3),
          radius: 100,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle_outline,
                size: 32,
                color: Color(0xFF757682),
              ),
              const SizedBox(height: 8),
              Text(
                'New Ledger Item',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF757682),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    const dashWidth = 10.0;
    const dashSpace = 5.0;
    var distance = 0.0;

    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

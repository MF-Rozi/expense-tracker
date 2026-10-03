import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Hidden configuration surface for streak parameters.
///
/// Full tuning controls arrive in Unit 6.
class StreakConfigSheet extends StatelessWidget {
  const StreakConfigSheet({
    super.key,
    this.initialType = StreakType.tracking,
  });

  final StreakType initialType;

  /// Convenience helper to display the sheet in a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    StreakType initialType = StreakType.tracking,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StreakConfigSheet(initialType: initialType),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Streak Settings',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00113A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure thresholds for ${initialType.displayName}',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF444650),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

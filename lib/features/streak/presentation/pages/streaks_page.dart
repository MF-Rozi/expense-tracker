import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Screen displaying detailed streak history, calendar, and milestones.
///
/// Full implementation arrives in Unit 7.
class StreaksPage extends StatelessWidget {
  const StreaksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Streaks',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00113A),
          ),
        ),
      ),
      body: const Center(
        child: Text('Streaks'),
      ),
    );
  }
}

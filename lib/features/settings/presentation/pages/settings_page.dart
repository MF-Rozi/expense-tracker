import 'package:expense_tracker/features/easter_egg/domain/entities/easter_egg_progress.dart';
import 'package:expense_tracker/features/easter_egg/presentation/blocs/easter_egg_cubit.dart';
import 'package:expense_tracker/injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, this.easterEggCubit});

  /// Overridable for tests; defaults to the app-wide singleton.
  final EasterEggCubit? easterEggCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EasterEggCubit>.value(
      value: easterEggCubit ?? getIt<EasterEggCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: BlocConsumer<EasterEggCubit, EasterEggState>(
          listenWhen: (previous, current) =>
              current.justRevealedHint && !previous.justRevealedHint,
          listener: (context, state) => _showRitualDialog(context),
          builder: (context, state) {
            final progress = state.progress;
            return ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('Manage Categories'),
                  subtitle:
                      const Text('Add or edit income and expense categories'),
                  onTap: () => context.push('/categories'),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Version'),
                  subtitle: Text(_versionSubtitle(progress)),
                  onTap: () => context.read<EasterEggCubit>().onVersionTapped(),
                ),
                if (progress.unlocked)
                  ListTile(
                    leading: const Icon(Icons.calculate_outlined),
                    title: const Text('Counter'),
                    subtitle: const Text('A long-forgotten classic'),
                    onTap: () => context.push('/counter'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _versionSubtitle(EasterEggProgress progress) {
    if (progress.unlocked) return 'Secret unlocked — Counter is below';
    if (!progress.hintSeen) return '1.0.0';
    return 'Something is stirring... '
        '(${progress.completedSteps}/${EasterEggProgress.totalSteps} steps)';
  }

  void _showRitualDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'You found something...',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'A long-forgotten page lies sealed inside this app. '
          'To open it, complete these steps:\n\n'
          '1. Log a transaction\n'
          '2. Visit the Stats tab\n'
          '3. Open your Categories\n\n'
          'Then come back here.',
          style: GoogleFonts.inter(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Got it',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

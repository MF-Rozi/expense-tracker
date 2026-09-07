import 'package:expense_tracker/features/counter/presentation/blocs/counter_cubit.dart';
import 'package:expense_tracker/features/easter_egg/presentation/blocs/easter_egg_cubit.dart';
import 'package:expense_tracker/injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// The hidden Counter Easter egg — unlocked through the Settings ritual.
/// Deliberately keeps the template's bare-bones logic; the joke is that
/// this page survived the cleanup that deleted everything else.
class CounterPage extends StatelessWidget {
  const CounterPage({super.key, this.easterEggCubit});

  /// Overridable for tests; defaults to the app-wide singleton.
  final EasterEggCubit? easterEggCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EasterEggCubit>.value(
      value: easterEggCubit ?? getIt<EasterEggCubit>(),
      child: BlocProvider(
        create: (_) => CounterCubit(),
        child: const CounterView(),
      ),
    );
  }
}

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Counter',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: const Color(0xFF00113A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Hide the secret room',
            icon: const Icon(Icons.visibility_off_outlined),
            onPressed: () {
              context.read<EasterEggCubit>().deactivate();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You found the secret room.',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF757682),
              ),
            ),
            const SizedBox(height: 8),
            const CounterText(),
            const SizedBox(height: 32),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _EggButton(
                  icon: Icons.remove,
                  onTap: () => context.read<CounterCubit>().decrement(),
                ),
                const SizedBox(width: 16),
                _EggButton(
                  icon: Icons.add,
                  onTap: () => context.read<CounterCubit>().increment(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CounterText extends StatelessWidget {
  const CounterText({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.select((CounterCubit cubit) => cubit.state);
    return Text(
      '$count',
      style: GoogleFonts.manrope(
        fontSize: 72,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF00113A),
      ),
    );
  }
}

class _EggButton extends StatelessWidget {
  const _EggButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F4F5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFC5C6D2)),
          ),
          child: Icon(icon, size: 28, color: const Color(0xFF00113A)),
        ),
      ),
    );
  }
}

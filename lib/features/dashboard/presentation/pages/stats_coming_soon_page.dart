import 'package:expense_tracker/features/easter_egg/presentation/blocs/easter_egg_cubit.dart';
import 'package:expense_tracker/injector.dart';
import 'package:flutter/material.dart';

class StatsComingSoonPage extends StatefulWidget {
  const StatsComingSoonPage({super.key});

  @override
  State<StatsComingSoonPage> createState() => _StatsComingSoonPageState();
}

class _StatsComingSoonPageState extends State<StatsComingSoonPage> {
  @override
  void initState() {
    super.initState();
    getIt<EasterEggCubit>().onStatsVisited();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Coming Soon'),
      ),
    );
  }
}

import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/presentation/blocs/streak_cubit.dart';
import 'package:expense_tracker/features/streak/presentation/blocs/streak_state.dart';
import 'package:expense_tracker/features/streak/presentation/widgets/milestone_progress.dart';
import 'package:expense_tracker/features/streak/presentation/widgets/streak_calendar.dart';
import 'package:expense_tracker/features/streak/presentation/widgets/streak_config_sheet.dart';
import 'package:expense_tracker/features/streak/presentation/widgets/streak_hero.dart';
import 'package:expense_tracker/injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Screen displaying detailed streak metrics, month calendar, and milestones.
class StreaksPage extends StatelessWidget {
  const StreaksPage({
    super.key,
    this.cubit,
    this.initialType,
  });

  final StreakCubit? cubit;
  final StreakType? initialType;

  StreakCubit _resolveCubit() {
    if (cubit != null) return cubit!;
    try {
      if (getIt.isRegistered<StreakCubit>()) {
        return getIt<StreakCubit>();
      }
    } catch (_) {}
    throw StateError('StreakCubit is not registered in dependency injection.');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final c = _resolveCubit();
        if (initialType != null && initialType != StreakType.tracking) {
          c.selectType(initialType!);
        } else {
          c.load();
        }
        return c;
      },
      child: const _StreaksPageView(),
    );
  }
}

class _StreaksPageView extends StatelessWidget {
  const _StreaksPageView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          'Streaks',
          style: GoogleFonts.manrope(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00113A),
          ),
        ),
        actions: [
          BlocBuilder<StreakCubit, StreakState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.tune_rounded),
                color: const Color(0xFF00113A),
                tooltip: 'Configure Streak',
                onPressed: () {
                  StreakConfigSheet.show(
                    context,
                    initialType: state.type,
                  );
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<StreakCubit, StreakState>(
        builder: (context, state) {
          if (state.isLoading && state.streak.length == 0) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00113A),
              ),
            );
          }

          final cubit = context.read<StreakCubit>();
          final hasData =
              !state.streak.isEmpty || state.qualifyingDays.isNotEmpty;

          return RefreshIndicator(
            color: const Color(0xFF00113A),
            onRefresh: cubit.load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTypeSelector(context, state.type),
                  const SizedBox(height: 20),
                  StreakHero(
                    streak: state.streak,
                    onLongPress: () {
                      StreakConfigSheet.show(
                        context,
                        initialType: state.type,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  StreakCalendar(
                    selectedMonth: state.displayMonth,
                    qualifyingDays: state.qualifyingDays,
                    onPreviousMonth: cubit.previousMonth,
                    onNextMonth: cubit.nextMonth,
                  ),
                  const SizedBox(height: 16),
                  StreakConsistencyCard(
                    consistencyRate: state.monthlyConsistencyRate,
                    hasData: hasData,
                  ),
                  const SizedBox(height: 24),
                  MilestoneProgress(streak: state.streak),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context, StreakType selectedType) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: StreakType.activeTypes.map((type) {
          final isSelected = type == selectedType;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onLongPress: () {
                StreakConfigSheet.show(
                  context,
                  initialType: type,
                );
              },
              child: ChoiceChip(
                key: Key('streak_type_chip_${type.name}'),
                label: Text(
                  type.shortLabel,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF00113A),
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    context.read<StreakCubit>().selectType(type);
                  }
                },
                selectedColor: const Color(0xFF00113A),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF00113A)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

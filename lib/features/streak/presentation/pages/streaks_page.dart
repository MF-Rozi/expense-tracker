import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/presentation/blocs/streak_cubit.dart';
import 'package:expense_tracker/features/streak/presentation/blocs/streak_state.dart';
import 'package:expense_tracker/features/streak/presentation/widgets/milestone_progress.dart';
import 'package:expense_tracker/features/streak/presentation/widgets/streak_calendar.dart';
import 'package:expense_tracker/features/streak/presentation/widgets/streak_config_sheet.dart';
import 'package:expense_tracker/features/streak/presentation/widgets/streak_hero.dart';
import 'package:expense_tracker/features/streak/presentation/widgets/under_budget_month_card.dart';
import 'package:expense_tracker/injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class StreaksPage extends StatelessWidget {
  const StreaksPage({
    super.key,
    this.cubit,
    this.initialType,
    this.referenceDate,
  });

  final StreakCubit? cubit;
  final StreakType? initialType;
  final DateTime? referenceDate;

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
      child: BlocBuilder<StreakCubit, StreakState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Scaffold(
              backgroundColor: const Color(0xFFF9FAFB),
              appBar: AppBar(
                backgroundColor: const Color(0xFFF9FAFB),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: const Color(0xFF00113A),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                title: Text(
                  'Streaks',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00113A),
                  ),
                ),
                centerTitle: true,
              ),
              body: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00113A),
                ),
              ),
            );
          }

          if (state.failureOption.isSome()) {
            return Scaffold(
              backgroundColor: const Color(0xFFF9FAFB),
              appBar: AppBar(
                backgroundColor: const Color(0xFFF9FAFB),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: const Color(0xFF00113A),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                title: Text(
                  'Streaks',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00113A),
                  ),
                ),
                centerTitle: true,
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFBA1A1A),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Unable to load streak data',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00113A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<StreakCubit>().load(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00113A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final cubit = context.read<StreakCubit>();
          final hasData = state.type == StreakType.underBudget
              ? (state.currentMonthBudget > 0 || !state.streak.isEmpty)
              : (!state.streak.isEmpty || state.qualifyingDays.isNotEmpty);

          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF9FAFB),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: const Color(0xFF00113A),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: Text(
                'Streaks',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00113A),
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  tooltip: 'Configure Streak',
                  icon: const Icon(Icons.tune_rounded),
                  color: const Color(0xFF00113A),
                  onPressed: () => StreakConfigSheet.show(
                    context,
                    initialType: state.type,
                  ),
                ),
              ],
            ),
            body: RefreshIndicator(
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
                    if (state.type == StreakType.underBudget)
                      UnderBudgetMonthCard(
                        selectedMonth: state.displayMonth,
                        status: state.underBudgetStatus,
                        isOnTrack: state.isOnTrack,
                        overrunFlags: state.categoryOverrunFlags,
                        referenceDate: referenceDate,
                        onPreviousMonth: cubit.previousMonth,
                        onNextMonth: cubit.nextMonth,
                      )
                    else
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
                label: Text(type.shortLabel),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    context.read<StreakCubit>().selectType(type);
                  }
                },
                selectedColor: const Color(0xFF00113A),
                backgroundColor: Colors.white,
                labelStyle: GoogleFonts.inter(
                  color: isSelected ? Colors.white : const Color(0xFF757682),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF00113A)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

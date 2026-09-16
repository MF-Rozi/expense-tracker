import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/presentation/mixins/failure_message_handler.dart';
import 'package:expense_tracker/features/easter_egg/presentation/blocs/easter_egg_cubit.dart';
import 'package:expense_tracker/features/insights/presentation/blocs/insights_cubit.dart';
import 'package:expense_tracker/features/insights/presentation/widgets/custom_range_picker_page.dart';
import 'package:expense_tracker/features/insights/presentation/widgets/envelope_drill_down_list.dart';
import 'package:expense_tracker/features/insights/presentation/widgets/insights_hero_card.dart';
import 'package:expense_tracker/features/insights/presentation/widgets/pillar_distribution_chart.dart';
import 'package:expense_tracker/features/insights/presentation/widgets/timeframe_filter_row.dart';
import 'package:expense_tracker/injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// The Insights screen: timeframe filter, gradient hero, pillar
/// distribution bar, and the per-envelope drill-down.
class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key, this.insightsCubit});

  /// Overridable for tests; defaults to the app-wide singleton.
  final InsightsCubit? insightsCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InsightsCubit>.value(
      value: insightsCubit ?? getIt<InsightsCubit>(),
      child: const _InsightsView(),
    );
  }
}

class _InsightsView extends StatefulWidget {
  const _InsightsView();

  @override
  State<_InsightsView> createState() => _InsightsViewState();
}

class _InsightsViewState extends State<_InsightsView>
    with FailureMessageHandler {
  @override
  void initState() {
    super.initState();
    // The easter-egg ritual step "visit the Stats tab" — the Insights
    // page replaced the placeholder, so the trigger moves with it.
    getIt<EasterEggCubit>().onStatsVisited();
    context.read<InsightsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Insights',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: const Color(0xFF00113A),
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
      ),
      body: BlocConsumer<InsightsCubit, InsightsState>(
        listener: (context, state) {
          state.failureOption.fold(
            () {},
            (failure) => handleFailure(context, failure),
          );
        },
        builder: (context, state) {
          if (state.status == InsightsStatus.loading && state.summary == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00113A)),
            );
          }

          final failure = state.failureOption.fold(() => null, (f) => f);

          return RefreshIndicator(
            onRefresh: () => context.read<InsightsCubit>().refresh(),
            color: const Color(0xFF00113A),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                if (failure != null && state.summary == null)
                  _buildFailureCard(failure)
                else ...[
                  TimeframeFilterRow(
                    selected: state.selectedTimeframe,
                    onTimeframeChanged: (timeframe) => context
                        .read<InsightsCubit>()
                        .selectTimeframe(timeframe),
                    onCustomSelected: () => _pickCustomRange(context),
                  ),
                  if (state.summary != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.summary!.periodLabel,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF757682),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InsightsHeroCard(summary: state.summary!),
                    const SizedBox(height: 16),
                    if (state.summary!.pillars.isEmpty)
                      _buildEmptyState()
                    else ...[
                      PillarDistributionChart(summary: state.summary!),
                      const SizedBox(height: 16),
                      EnvelopeDrillDownList(
                        pillars: state.summary!.pillars,
                      ),
                    ],
                  ] else ...[
                    _buildEmptyState(),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// Content stays visible through a refetch failure when a previous
  /// summary exists — the failure surfaces as a flash only.

  Widget _buildFailureCard(Failure failure) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFDAD6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFBA1A1A)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Could not load insights. Pull to retry.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF444650),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCustomRange(BuildContext context) async {
    final picked = await Navigator.of(context).push<DateTimeRange>(
      MaterialPageRoute<DateTimeRange>(
        fullscreenDialog: true,
        builder: (_) => const CustomRangePickerPage(),
      ),
    );
    if (picked == null || !context.mounted) return;
    await context
        .read<InsightsCubit>()
        .selectCustomRange(picked.start, picked.end);
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.insights_outlined,
            size: 48,
            color: Color(0xFF757682),
          ),
          const SizedBox(height: 12),
          Text(
            'Nothing to analyze yet',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00113A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Log a transaction in this period and it will show up here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF444650),
            ),
          ),
        ],
      ),
    );
  }
}

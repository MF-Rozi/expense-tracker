import 'package:expense_tracker/core/storages/local_storages.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/presentation/blocs/streak_config_cubit.dart';
import 'package:expense_tracker/features/streak/presentation/blocs/streak_config_state.dart';
import 'package:expense_tracker/injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Hidden configuration tuning surface for streak parameters.
///
/// Long-pressing any streak element opens this sheet at the requested section.
/// Changes persist to [LocalStorage] and take effect immediately on next read.
class StreakConfigSheet extends StatefulWidget {
  const StreakConfigSheet({
    super.key,
    this.initialType = StreakType.tracking,
    this.cubit,
  });

  /// Deep-linked section to focus when opened.
  final StreakType initialType;

  /// Optional injected cubit (used in tests or manual overrides).
  final StreakConfigCubit? cubit;

  /// Convenience helper to display the sheet in a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    StreakType initialType = StreakType.tracking,
    StreakConfigCubit? cubit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StreakConfigSheet(
        initialType: initialType,
        cubit: cubit,
      ),
    );
  }

  @override
  State<StreakConfigSheet> createState() => _StreakConfigSheetState();
}

class _StreakConfigSheetState extends State<StreakConfigSheet> {
  late final StreakConfigCubit _cubit;
  bool _ownsCubit = false;

  @override
  void initState() {
    super.initState();
    if (widget.cubit != null) {
      _cubit = widget.cubit!;
    } else {
      try {
        _cubit = context.read<StreakConfigCubit>();
      } catch (_) {
        if (getIt.isRegistered<StreakConfigCubit>()) {
          _cubit = getIt<StreakConfigCubit>()
            ..load(initialType: widget.initialType);
        } else if (getIt.isRegistered<LocalStorage>()) {
          _cubit = StreakConfigCubit(getIt<LocalStorage>())
            ..load(initialType: widget.initialType);
        } else {
          _cubit = StreakConfigCubit(const _FallbackLocalStorage())
            ..load(initialType: widget.initialType);
        }
        _ownsCubit = true;
      }
    }
  }

  @override
  void dispose() {
    if (_ownsCubit) {
      _cubit.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StreakConfigCubit>.value(
      value: _cubit,
      child: BlocBuilder<StreakConfigCubit, StreakConfigState>(
        builder: (context, state) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Streak Settings',
                              style: GoogleFonts.manrope(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00113A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tune gap allowances and thresholds',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF444650),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF444650),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTypeSelector(context, state.selectedType),
                    const SizedBox(height: 24),
                    if (state.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(
                            color: Color(0xFF00113A),
                          ),
                        ),
                      )
                    else
                      _buildSectionContent(context, state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeSelector(
    BuildContext context,
    StreakType selectedType,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: StreakType.values.map((type) {
          final isSelected = type == selectedType;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              key: Key('streak_config_type_${type.name}'),
              label: Text(
                _typeShortLabel(type),
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF444650),
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                context.read<StreakConfigCubit>().selectType(type);
              },
              selectedColor: const Color(0xFF00113A),
              backgroundColor: const Color(0xFFF1F2F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionContent(
    BuildContext context,
    StreakConfigState state,
  ) {
    switch (state.selectedType) {
      case StreakType.tracking:
        return _buildTrackingSection(context, state);
      case StreakType.appOpen:
        return _buildAppOpenSection(context, state);
      case StreakType.noSpend:
        return _buildReservedPlaceholder(
          title: 'No-Spend Streak',
          badge: 'Phase 2',
          description:
              'No-spend streaks qualify days when no expenses are recorded. '
              'Tuning controls will unlock when Phase 2 ships.',
          icon: Icons.savings_outlined,
        );
      case StreakType.underBudget:
        return _buildReservedPlaceholder(
          title: 'Under-Budget Streak',
          badge: 'Phase 3',
          description:
              'Under-budget streaks evaluate monthly envelope discipline. '
              'Tuning controls will unlock when Phase 3 ships.',
          icon: Icons.account_balance_wallet_outlined,
        );
    }
  }

  Widget _buildTrackingSection(
    BuildContext context,
    StreakConfigState state,
  ) {
    final cubit = context.read<StreakConfigCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepperCard(
          title: 'Window Gap Allowance',
          subtitle:
              'Maximum consecutive days allowed between transactions '
              'without breaking the run.',
          value: state.config.window,
          decrementKey: const Key('window_decrement'),
          incrementKey: const Key('window_increment'),
          valueKey: const Key('window_value'),
          onDecrement: cubit.decrementWindow,
          onIncrement: cubit.incrementWindow,
        ),
        const SizedBox(height: 16),
        _buildStepperCard(
          title: 'Activation Threshold',
          subtitle:
              'Days required to celebrate your streak as active. Below this, '
              'it is framed as warming up.',
          value: state.config.minimum,
          decrementKey: const Key('minimum_decrement'),
          incrementKey: const Key('minimum_increment'),
          valueKey: const Key('minimum_value'),
          onDecrement: cubit.decrementMinimum,
          onIncrement: cubit.incrementMinimum,
        ),
      ],
    );
  }

  Widget _buildAppOpenSection(
    BuildContext context,
    StreakConfigState state,
  ) {
    final cubit = context.read<StreakConfigCubit>();
    const presets = [1, 2, 3, 7];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'App-Open Cadence',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00113A),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Phase 2 Preview',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D4ED8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Target interval in days for app visits. '
          'Cadence 1 requires daily opens.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF444650),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Quick Presets',
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF00113A),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: presets.map((p) {
            final isSelected = state.config.cadence == p;
            final label = p == 1
                ? 'Daily (1d)'
                : p == 7
                    ? 'Weekly (7d)'
                    : '$p days';
            return ActionChip(
              key: Key('cadence_preset_$p'),
              label: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF00113A),
                ),
              ),
              backgroundColor: isSelected
                  ? const Color(0xFF00113A)
                  : const Color(0xFFF1F2F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              onPressed: () => cubit.updateCadence(p),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildStepperCard(
          title: 'Custom Cadence',
          subtitle: 'Adjust cadence step-by-step.',
          value: state.config.cadence,
          decrementKey: const Key('cadence_decrement'),
          incrementKey: const Key('cadence_increment'),
          valueKey: const Key('cadence_value'),
          onDecrement: cubit.decrementCadence,
          onIncrement: cubit.incrementCadence,
        ),
      ],
    );
  }

  Widget _buildReservedPlaceholder({
    required String title,
    required String badge,
    required String description,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFE5E7EB),
            child: Icon(
              icon,
              size: 28,
              color: const Color(0xFF757682),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00113A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F2F6),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF757682),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF444650),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Reserved Placeholder',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF757682),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperCard({
    required String title,
    required String subtitle,
    required int value,
    required Key decrementKey,
    required Key incrementKey,
    required Key valueKey,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00113A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF444650),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$value ${value == 1 ? 'day' : 'days'}',
                key: valueKey,
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00113A),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    key: decrementKey,
                    onPressed: value > 1 ? onDecrement : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: const Color(0xFF00113A),
                    disabledColor: const Color(0xFFBDBDBD),
                  ),
                  IconButton(
                    key: incrementKey,
                    onPressed: onIncrement,
                    icon: const Icon(Icons.add_circle_outline),
                    color: const Color(0xFF00113A),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _typeShortLabel(StreakType type) {
    switch (type) {
      case StreakType.tracking:
        return 'Tracking';
      case StreakType.noSpend:
        return 'No-Spend';
      case StreakType.appOpen:
        return 'App-Open';
      case StreakType.underBudget:
        return 'Under-Budget';
    }
  }
}

class _FallbackLocalStorage implements LocalStorage {
  const _FallbackLocalStorage();

  @override
  Future<String?> getApiKey() => Future.value();

  @override
  Future<void> setApiKey(String apiKey) => Future.value();

  @override
  Future<int> getStreakWindowDays() => Future.value(3);

  @override
  Future<void> setStreakWindowDays(int days) => Future.value();

  @override
  Future<int> getStreakMinimumDays() => Future.value(3);

  @override
  Future<void> setStreakMinimumDays(int days) => Future.value();

  @override
  Future<int> getAppOpenCadenceDays() => Future.value(7);

  @override
  Future<void> setAppOpenCadenceDays(int days) => Future.value();
}

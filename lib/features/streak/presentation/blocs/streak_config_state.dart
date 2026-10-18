import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_config.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';

/// State of the streak configuration tuning surface.
class StreakConfigState extends Equatable {
  const StreakConfigState({
    this.isLoading = true,
    this.config = const StreakConfig(),
    this.selectedType = StreakType.tracking,
  });

  /// Whether config values are being read from storage.
  final bool isLoading;

  /// Current tuning parameters.
  final StreakConfig config;

  /// Currently focused streak section tab.
  final StreakType selectedType;

  StreakConfigState copyWith({
    bool? isLoading,
    StreakConfig? config,
    StreakType? selectedType,
  }) {
    return StreakConfigState(
      isLoading: isLoading ?? this.isLoading,
      config: config ?? this.config,
      selectedType: selectedType ?? this.selectedType,
    );
  }

  @override
  List<Object?> get props => [isLoading, config, selectedType];
}

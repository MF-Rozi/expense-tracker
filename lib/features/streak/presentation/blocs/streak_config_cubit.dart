import 'package:expense_tracker/core/storages/local_storages.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_config.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/presentation/blocs/streak_config_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Cubit managing user-customizable streak parameters.
///
/// Persists all values to [LocalStorage]. Clamps input values to >= 1.
@injectable
class StreakConfigCubit extends Cubit<StreakConfigState> {
  StreakConfigCubit(this._localStorage) : super(const StreakConfigState());

  final LocalStorage _localStorage;

  /// Loads stored configuration and selects the [initialType] section.
  Future<void> load({StreakType initialType = StreakType.tracking}) async {
    emit(state.copyWith(isLoading: true, selectedType: initialType));

    final window = await _localStorage.getStreakWindowDays();
    final minimum = await _localStorage.getStreakMinimumDays();
    final cadence = await _localStorage.getAppOpenCadenceDays();

    emit(
      state.copyWith(
        isLoading: false,
        selectedType: initialType,
        config: StreakConfig(
          window: window,
          minimum: minimum,
          cadence: cadence,
        ),
      ),
    );
  }

  /// Switches the active section tab in the sheet.
  void selectType(StreakType type) {
    emit(state.copyWith(selectedType: type));
  }

  /// Sets the tracking window in days (clamped >= 1) and persists.
  Future<void> updateWindow(int days) async {
    final clamped = days < 1 ? 1 : days;
    await _localStorage.setStreakWindowDays(clamped);
    emit(state.copyWith(config: state.config.copyWith(window: clamped)));
  }

  /// Increments the tracking window by 1 day.
  Future<void> incrementWindow() => updateWindow(state.config.window + 1);

  /// Decrements the tracking window by 1 day (minimum 1).
  Future<void> decrementWindow() => updateWindow(state.config.window - 1);

  /// Sets the minimum activation threshold in days (clamped >= 1) and persists.
  Future<void> updateMinimum(int days) async {
    final clamped = days < 1 ? 1 : days;
    await _localStorage.setStreakMinimumDays(clamped);
    emit(state.copyWith(config: state.config.copyWith(minimum: clamped)));
  }

  /// Increments the minimum activation threshold by 1 day.
  Future<void> incrementMinimum() => updateMinimum(state.config.minimum + 1);

  /// Decrements the minimum activation threshold by 1 day (minimum 1).
  Future<void> decrementMinimum() => updateMinimum(state.config.minimum - 1);

  /// Sets the app-open cadence in days (clamped >= 1) and persists.
  Future<void> updateCadence(int days) async {
    final clamped = days < 1 ? 1 : days;
    await _localStorage.setAppOpenCadenceDays(clamped);
    emit(state.copyWith(config: state.config.copyWith(cadence: clamped)));
  }

  /// Increments the app-open cadence by 1 day.
  Future<void> incrementCadence() => updateCadence(state.config.cadence + 1);

  /// Decrements the app-open cadence by 1 day (minimum 1).
  Future<void> decrementCadence() => updateCadence(state.config.cadence - 1);
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/easter_egg/data/datasources/easter_egg_storage.dart';
import 'package:expense_tracker/features/easter_egg/domain/entities/easter_egg_progress.dart';
import 'package:expense_tracker/shared/flash/presentation/blocs/cubit/flash_cubit.dart';
import 'package:injectable/injectable.dart';

part 'easter_egg_state.dart';

/// Drives the hidden Counter Easter egg:
/// 1. Tap the Settings version row [EasterEggProgress.versionTapsRequired]
///    times to reveal the ritual hint.
/// 2. Complete the three steps (log a transaction, visit Stats, open
///    Categories) — steps only count once the hint has been seen.
/// 3. Unlock flashes a celebration and adds a Counter entry in Settings.
/// 4. Hiding from the Counter screen re-locks everything ([deactivate]),
///    requiring the ritual to be completed again.
@lazySingleton
class EasterEggCubit extends Cubit<EasterEggState> {
  EasterEggCubit(this._storage, this._flashCubit)
      : super(const EasterEggState()) {
    _restore();
  }

  final EasterEggStorage _storage;
  final FlashCubit _flashCubit;

  void _restore() {
    emit(EasterEggState(progress: _storage.read()));
  }

  void onVersionTapped() {
    final current = state.progress;
    if (current.unlocked) return;

    var progress = current.copyWith(versionTaps: current.versionTaps + 1);
    var justRevealedHint = false;
    if (!progress.hintSeen &&
        progress.versionTaps >=
            EasterEggProgress.versionTapsRequired) {
      progress = progress.copyWith(hintSeen: true);
      justRevealedHint = true;
    }

    unawaited(_storage.write(progress));
    emit(
      EasterEggState(
        progress: progress,
        justRevealedHint: justRevealedHint,
      ),
    );
  }

  void onTransactionLogged() =>
      _completeStep((p) => p.copyWith(loggedTransaction: true));

  /// Hides the Counter again — like Android's developer options, closing
  /// it resets the entire ritual so it must be unlocked from scratch.
  void deactivate() {
    if (!state.progress.unlocked) return;

    const reset = EasterEggProgress();
    unawaited(_storage.write(reset));
    emit(const EasterEggState());
    unawaited(
      _flashCubit.displayFlash(
        'Counter locked again — repeat the ritual to reopen it.',
      ),
    );
  }

  void onStatsVisited() => _completeStep((p) => p.copyWith(visitedStats: true));

  void onCategoriesOpened() =>
      _completeStep((p) => p.copyWith(openedCategories: true));

  void _completeStep(EasterEggProgress Function(EasterEggProgress) update) {
    final current = state.progress;
    if (!current.hintSeen || current.unlocked) return;

    final stepped = update(current);
    if (stepped == current) return;

    var progress = stepped;
    if (progress.completedSteps == 3) {
      progress = progress.copyWith(unlocked: true);
      unawaited(
        _flashCubit.displayFlash(
          'Secret unlocked! Counter is now available in Settings.',
        ),
      );
    }

    unawaited(_storage.write(progress));
    emit(EasterEggState(progress: progress));
  }
}

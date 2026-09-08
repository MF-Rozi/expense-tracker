import 'dart:convert';

import 'package:expense_tracker/features/easter_egg/domain/entities/easter_egg_progress.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class EasterEggStorage {
  EasterEggProgress read();
  Future<void> write(EasterEggProgress progress);
}

/// Persists the ritual as one atomic JSON snapshot. Separate keys would
/// allow torn writes (e.g. steps persisted without the unlocked flag),
/// which no in-process code can distinguish from an intentional state.
@LazySingleton(as: EasterEggStorage)
class EasterEggStorageImpl implements EasterEggStorage {
  const EasterEggStorageImpl(this._preferences);

  final SharedPreferences _preferences;

  static const _progressKey = 'easterEgg.progress';

  @override
  EasterEggProgress read() {
    final raw = _preferences.getString(_progressKey);
    if (raw == null) return const EasterEggProgress();
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return EasterEggProgress(
      versionTaps: map['versionTaps'] as int? ?? 0,
      hintSeen: map['hintSeen'] as bool? ?? false,
      loggedTransaction: map['loggedTransaction'] as bool? ?? false,
      visitedStats: map['visitedStats'] as bool? ?? false,
      openedCategories: map['openedCategories'] as bool? ?? false,
      unlocked: map['unlocked'] as bool? ?? false,
    );
  }

  @override
  Future<void> write(EasterEggProgress progress) {
    return _preferences.setString(
      _progressKey,
      jsonEncode({
        'versionTaps': progress.versionTaps,
        'hintSeen': progress.hintSeen,
        'loggedTransaction': progress.loggedTransaction,
        'visitedStats': progress.visitedStats,
        'openedCategories': progress.openedCategories,
        'unlocked': progress.unlocked,
      }),
    );
  }
}

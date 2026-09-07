import 'package:expense_tracker/features/easter_egg/domain/entities/easter_egg_progress.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class EasterEggStorage {
  EasterEggProgress read();
  Future<void> write(EasterEggProgress progress);
}

@LazySingleton(as: EasterEggStorage)
class EasterEggStorageImpl implements EasterEggStorage {
  const EasterEggStorageImpl(this._preferences);

  final SharedPreferences _preferences;

  static const _tapsKey = 'easterEgg.versionTaps';
  static const _hintKey = 'easterEgg.hintSeen';
  static const _transactionKey = 'easterEgg.loggedTransaction';
  static const _statsKey = 'easterEgg.visitedStats';
  static const _categoriesKey = 'easterEgg.openedCategories';
  static const _unlockedKey = 'easterEgg.unlocked';

  @override
  EasterEggProgress read() {
    return EasterEggProgress(
      versionTaps: _preferences.getInt(_tapsKey) ?? 0,
      hintSeen: _preferences.getBool(_hintKey) ?? false,
      loggedTransaction: _preferences.getBool(_transactionKey) ?? false,
      visitedStats: _preferences.getBool(_statsKey) ?? false,
      openedCategories: _preferences.getBool(_categoriesKey) ?? false,
      unlocked: _preferences.getBool(_unlockedKey) ?? false,
    );
  }

  @override
  Future<void> write(EasterEggProgress progress) async {
    await Future.wait([
      _preferences.setInt(_tapsKey, progress.versionTaps),
      _preferences.setBool(_hintKey, progress.hintSeen),
      _preferences.setBool(_transactionKey, progress.loggedTransaction),
      _preferences.setBool(_statsKey, progress.visitedStats),
      _preferences.setBool(_categoriesKey, progress.openedCategories),
      _preferences.setBool(_unlockedKey, progress.unlocked),
    ]);
  }
}

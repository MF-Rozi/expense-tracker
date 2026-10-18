import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorage {
  Future<String?> getApiKey();
  Future<void> setApiKey(String apiKey);

  Future<int> getStreakWindowDays();
  Future<void> setStreakWindowDays(int days);

  Future<int> getStreakMinimumDays();
  Future<void> setStreakMinimumDays(int days);

  Future<int> getAppOpenCadenceDays();
  Future<void> setAppOpenCadenceDays(int days);
}

@LazySingleton(as: LocalStorage)
class LocalStorageImpl implements LocalStorage {
  const LocalStorageImpl(this._storage);

  final SharedPreferences _storage;

  static const _apiKeyKey = 'apiKey';
  static const _streakWindowDaysKey = 'streakWindowDays';
  static const _streakMinimumDaysKey = 'streakMinimumDays';
  static const _appOpenCadenceDaysKey = 'appOpenCadenceDays';

  static const defaultStreakWindowDays = 3;
  static const defaultStreakMinimumDays = 3;
  static const defaultAppOpenCadenceDays = 7;

  @override
  Future<String?> getApiKey() {
    return Future.value(_storage.getString(_apiKeyKey));
  }

  @override
  Future<void> setApiKey(String apiKey) async {
    await _storage.setString(_apiKeyKey, apiKey);
  }

  @override
  Future<int> getStreakWindowDays() {
    final value = _storage.getInt(_streakWindowDaysKey);
    if (value == null) {
      return Future.value(defaultStreakWindowDays);
    }
    return Future.value(value < 1 ? 1 : value);
  }

  @override
  Future<void> setStreakWindowDays(int days) async {
    final clamped = days < 1 ? 1 : days;
    await _storage.setInt(_streakWindowDaysKey, clamped);
  }

  @override
  Future<int> getStreakMinimumDays() {
    final value = _storage.getInt(_streakMinimumDaysKey);
    if (value == null) {
      return Future.value(defaultStreakMinimumDays);
    }
    return Future.value(value < 1 ? 1 : value);
  }

  @override
  Future<void> setStreakMinimumDays(int days) async {
    final clamped = days < 1 ? 1 : days;
    await _storage.setInt(_streakMinimumDaysKey, clamped);
  }

  @override
  Future<int> getAppOpenCadenceDays() {
    final value = _storage.getInt(_appOpenCadenceDaysKey);
    if (value == null) {
      return Future.value(defaultAppOpenCadenceDays);
    }
    return Future.value(value < 1 ? 1 : value);
  }

  @override
  Future<void> setAppOpenCadenceDays(int days) async {
    final clamped = days < 1 ? 1 : days;
    await _storage.setInt(_appOpenCadenceDaysKey, clamped);
  }
}

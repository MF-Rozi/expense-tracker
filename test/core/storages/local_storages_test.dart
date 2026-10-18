import 'package:expense_tracker/core/storages/local_storages.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalStorageImpl', () {
    test('unset keys return default values (3, 3, 7) and null for apiKey',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageImpl(prefs);

      expect(await storage.getApiKey(), isNull);
      expect(await storage.getStreakWindowDays(), 3);
      expect(await storage.getStreakMinimumDays(), 3);
      expect(await storage.getAppOpenCadenceDays(), 7);
    });

    test('round-trip set and get for apiKey', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageImpl(prefs);

      await storage.setApiKey('test-api-key-123');
      expect(await storage.getApiKey(), 'test-api-key-123');
    });

    test('round-trip set and get for streakWindowDays', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageImpl(prefs);

      await storage.setStreakWindowDays(5);
      expect(await storage.getStreakWindowDays(), 5);
    });

    test('round-trip set and get for streakMinimumDays', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageImpl(prefs);

      await storage.setStreakMinimumDays(4);
      expect(await storage.getStreakMinimumDays(), 4);
    });

    test('round-trip set and get for appOpenCadenceDays', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageImpl(prefs);

      await storage.setAppOpenCadenceDays(14);
      expect(await storage.getAppOpenCadenceDays(), 14);
    });

    test('clamps out-of-range stored value (0 or negative) on read', () async {
      SharedPreferences.setMockInitialValues({
        'streakWindowDays': 0,
        'streakMinimumDays': -5,
        'appOpenCadenceDays': -1,
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageImpl(prefs);

      expect(await storage.getStreakWindowDays(), 1);
      expect(await storage.getStreakMinimumDays(), 1);
      expect(await storage.getAppOpenCadenceDays(), 1);
    });

    test('clamps out-of-range value (0 or negative) on set', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageImpl(prefs);

      await storage.setStreakWindowDays(0);
      expect(await storage.getStreakWindowDays(), 1);

      await storage.setStreakMinimumDays(-2);
      expect(await storage.getStreakMinimumDays(), 1);

      await storage.setAppOpenCadenceDays(-10);
      expect(await storage.getAppOpenCadenceDays(), 1);
    });
  });
}

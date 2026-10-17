import 'package:expense_tracker/features/streak/data/models/app_open_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppOpenModel', () {
    test('create factory instantiates model with uuid and date', () {
      final now = DateTime(2026, 9, 26, 10, 30);
      final model = AppOpenModel.create(
        uuid: 'open-123',
        date: now,
      );

      expect(model.uuid, equals('open-123'));
      expect(model.date, equals(now));
    });

    test(
        'multiple opens on same day persist as separate records with '
        'unique uuids', () {
      final date = DateTime(2026, 9, 26);
      final morningOpen = AppOpenModel.create(
        uuid: 'open-morning',
        date: DateTime(date.year, date.month, date.day, 8),
      );
      final eveningOpen = AppOpenModel.create(
        uuid: 'open-evening',
        date: DateTime(date.year, date.month, date.day, 20),
      );

      expect(morningOpen.uuid, isNot(equals(eveningOpen.uuid)));
      expect(morningOpen.date.day, equals(eveningOpen.date.day));
    });
  });
}

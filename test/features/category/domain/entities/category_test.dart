import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Category', () {
    test('represents a root category', () {
      final category = Category(
        uuid: UniqueId('f398a930-77b3-4395-be13-4bc5b53cb2f9'),
        name: StringSingleLine('Food'),
        isSynced: false,
        updatedAt: DateTime.utc(2026, 6, 3),
      );

      expect(category.isRoot, isTrue);
      expect(category.parentUuid, isNull);
      expect(category.props, [
        category.uuid,
        category.name,
        null,
        false,
        DateTime.utc(2026, 6, 3),
      ]);
    });

    test('represents a child category', () {
      final parentUuid = UniqueId('a7d7b2f7-4d18-43f0-bf8f-4f3f6d9f4b3b');
      final category = Category(
        uuid: UniqueId('b3f76e40-4f1f-4c40-9d16-1c3a4f8a0f11'),
        name: StringSingleLine('Groceries'),
        parentUuid: parentUuid,
        isSynced: true,
        updatedAt: DateTime.utc(2026, 6, 3, 12),
      );

      expect(category.isRoot, isFalse);
      expect(category.parentUuid, parentUuid);
      expect(category.props, [
        category.uuid,
        category.name,
        parentUuid,
        true,
        DateTime.utc(2026, 6, 3, 12),
      ]);
    });
  });
}

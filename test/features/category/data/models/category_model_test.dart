import 'package:flutter_test/flutter_test.dart';
import 'package:template/features/category/data/models/category_model.dart';
import 'package:template/features/category/domain/entities/category.dart';
import 'package:template/shared/domain/entities/value_objects.dart';

void main() {
  group('CategoryModel', () {
    final tUuid = UniqueId('550e8400-e29b-41d4-a716-446655440000');
    final tParentUuid = UniqueId('550e8400-e29b-41d4-a716-446655440001');
    final tDate = DateTime(2026, 6, 3);
    
    final tCategory = Category(
      uuid: tUuid,
      name: StringSingleLine('Food'),
      isSynced: false,
      updatedAt: tDate,
      parentUuid: tParentUuid,
    );

    test('should map from entity correctly', () {
      final model = CategoryModel.fromEntity(tCategory);

      expect(model.uuid, tUuid.getOrCrash());
      expect(model.name, 'Food');
      expect(model.isSynced, false);
      expect(model.updatedAt, tDate);
      expect(model.parentUuid, tParentUuid.getOrCrash());
    });

    test('should map to entity correctly', () {
      final model = CategoryModel()
        ..uuid = tUuid.getOrCrash()
        ..name = 'Food'
        ..isSynced = false
        ..updatedAt = tDate
        ..parentUuid = tParentUuid.getOrCrash();

      final entity = model.toEntity();

      expect(entity, tCategory);
    });

    test('should handle null parentUuid correctly', () {
      final rootCategory = Category(
        uuid: tUuid,
        name: StringSingleLine('Root'),
        isSynced: true,
        updatedAt: tDate,
        parentUuid: null,
      );

      final model = CategoryModel.fromEntity(rootCategory);
      expect(model.parentUuid, isNull);

      final entity = model.toEntity();
      expect(entity.parentUuid, isNull);
    });
  });
}

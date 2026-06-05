import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:template/core/domain/failures/failure.dart';
import 'package:template/features/category/data/datasources/category_local_data_source.dart';
import 'package:template/features/category/data/models/category_model.dart';
import 'package:template/features/category/data/repositories/category_repository_impl.dart';
import 'package:template/features/category/domain/entities/category.dart';
import 'package:template/shared/domain/entities/value_objects.dart';

class MockCategoryLocalDataSource extends Mock implements CategoryLocalDataSource {}

void main() {
  late CategoryRepositoryImpl repository;
  late MockCategoryLocalDataSource mockDataSource;

  setUpAll(() {
    registerFallbackValue(CategoryModelFake());
  });

  setUp(() {
    mockDataSource = MockCategoryLocalDataSource();
    repository = CategoryRepositoryImpl(mockDataSource);
  });

  group('saveCategory', () {
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

    final tCategoryModel = CategoryModel.fromEntity(tCategory);

    test('should return Right(unit) when saving a root category', () async {
      final rootCategory = Category(
        uuid: tUuid,
        name: StringSingleLine('Root'),
        isSynced: false,
        updatedAt: tDate,
        parentUuid: null,
      );
      
      when(() => mockDataSource.saveCategory(any()))
          .thenAnswer((_) async => {});

      final result = await repository.saveCategory(rootCategory);

      expect(result, const Right(unit));
      verify(() => mockDataSource.saveCategory(any())).called(1);
    });

    test('should return Right(unit) when saving a child category with existing parent', () async {
      when(() => mockDataSource.getCategoryByUuid(any()))
          .thenAnswer((_) async => CategoryModel());
      when(() => mockDataSource.saveCategory(any()))
          .thenAnswer((_) async => {});

      final result = await repository.saveCategory(tCategory);

      expect(result, const Right(unit));
      verify(() => mockDataSource.getCategoryByUuid(tParentUuid.getOrCrash())).called(1);
      verify(() => mockDataSource.saveCategory(any())).called(1);
    });

    test('should return Left(Failure) when saving a child category with missing parent', () async {
      when(() => mockDataSource.getCategoryByUuid(any()))
          .thenAnswer((_) async => null);

      final result = await repository.saveCategory(tCategory);

      expect(result, const Left(Failure.localFailure(message: 'Parent category not found')));
      verify(() => mockDataSource.getCategoryByUuid(tParentUuid.getOrCrash())).called(1);
      verifyNever(() => mockDataSource.saveCategory(any()));
    });
  });

  group('deleteCategory', () {
    final tUuid = UniqueId('550e8400-e29b-41d4-a716-446655440000');

    test('should delegate to data source', () async {
      when(() => mockDataSource.deleteCategoryWithDescendants(any()))
          .thenAnswer((_) async => {});

      final result = await repository.deleteCategory(tUuid);

      expect(result, const Right(unit));
      verify(() => mockDataSource.deleteCategoryWithDescendants(tUuid.getOrCrash())).called(1);
    });
  });

  group('watchCategories', () {
    test('should return stream of categories', () async {
      final models = [
        CategoryModel()
          ..uuid = '550e8400-e29b-41d4-a716-446655440002'
          ..name = 'C1'
          ..isSynced = false
          ..updatedAt = DateTime.now()
      ];
      when(() => mockDataSource.watchCategories())
          .thenAnswer((_) => Stream.value(models));

      final result = await repository.watchCategories().first;

      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should be Right'),
        (r) => expect(r.length, 1),
      );
    });
  });
}

// Need to register fallback value for CategoryModel for mocktail
class CategoryModelFake extends Fake implements CategoryModel {}

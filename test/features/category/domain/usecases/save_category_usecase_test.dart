import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/category/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/category/domain/usecases/save_category_usecase.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  group('SaveCategoryUseCase', () {
    late CategoryRepository repository;
    late SaveCategoryUseCase useCase;

    setUp(() {
      repository = MockCategoryRepository();
      useCase = SaveCategoryUseCase(repository);
    });

    test('delegates to the repository', () async {
      final category = Category(
        uuid: UniqueId('f398a930-77b3-4395-be13-4bc5b53cb2f9'),
        name: StringSingleLine('Food'),
        isSynced: false,
        updatedAt: DateTime.utc(2026, 6, 3),
      );
      when(() => repository.saveCategory(category)).thenAnswer(
        (_) async => right<Failure, Unit>(unit),
      );

      final result = await useCase.call(SaveCategoryParams(category));

      expect(result, right<Failure, Unit>(unit));
      verify(() => repository.saveCategory(category)).called(1);
    });
  });
}

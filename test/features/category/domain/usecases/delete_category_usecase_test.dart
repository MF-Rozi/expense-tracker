import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/category/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/category/domain/usecases/delete_category_usecase.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  group('DeleteCategoryUseCase', () {
    late CategoryRepository repository;
    late DeleteCategoryUseCase useCase;

    setUp(() {
      repository = MockCategoryRepository();
      useCase = DeleteCategoryUseCase(repository);
    });

    test('delegates to the repository', () async {
      final categoryUuid = UniqueId('f398a930-77b3-4395-be13-4bc5b53cb2f9');
      when(() => repository.deleteCategory(categoryUuid)).thenAnswer(
        (_) async => right<Failure, Unit>(unit),
      );

      final result = await useCase.call(DeleteCategoryParams(categoryUuid));

      expect(result, right<Failure, Unit>(unit));
      verify(() => repository.deleteCategory(categoryUuid)).called(1);
    });
  });
}

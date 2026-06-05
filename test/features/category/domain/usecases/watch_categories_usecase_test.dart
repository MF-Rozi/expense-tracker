import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:template/core/domain/failures/failure.dart';
import 'package:template/core/domain/usecases/use_case.dart';
import 'package:template/core/extensions/dartz_extensions.dart';
import 'package:template/features/category/domain/entities/category.dart';
import 'package:template/features/category/domain/repositories/category_repository.dart';
import 'package:template/features/category/domain/usecases/watch_categories_usecase.dart';
import 'package:template/shared/domain/entities/value_objects.dart';

class FakeCategoryRepository implements CategoryRepository {
  FakeCategoryRepository(this._stream);

  final Stream<Either<Failure, List<Category>>> _stream;

  @override
  Stream<Either<Failure, List<Category>>> watchCategories() => _stream;

  @override
  Future<Either<Failure, Unit>> deleteCategory(UniqueId categoryUuid) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> saveCategory(Category category) {
    throw UnimplementedError();
  }
}

void main() {
  group('WatchCategoriesUseCase', () {
    test('returns the repository stream', () async {
      final category = Category(
        uuid: UniqueId('f398a930-77b3-4395-be13-4bc5b53cb2f9'),
        name: StringSingleLine('Food'),
        isSynced: true,
        updatedAt: DateTime.utc(2026, 6, 3),
      );
      final stream = Stream<Either<Failure, List<Category>>>.value(
        right<Failure, List<Category>>([category]),
      );
      final useCase = WatchCategoriesUseCase(FakeCategoryRepository(stream));

      final output = await useCase.call(NoParams()).first;

      expect(output.getRight(), [category]);
    });
  });
}

import 'package:dartz/dartz.dart';
import 'package:template/core/domain/failures/failure.dart';
import 'package:template/features/category/domain/entities/category.dart';
import 'package:template/shared/domain/entities/value_objects.dart';

abstract class CategoryRepository {
  Stream<Either<Failure, List<Category>>> watchCategories();

  Future<Either<Failure, Unit>> saveCategory(Category category);

  Future<Either<Failure, Unit>> deleteCategory(UniqueId categoryUuid);
}

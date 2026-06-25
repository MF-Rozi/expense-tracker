import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';

abstract class CategoryRepository {
  Stream<Either<Failure, List<Category>>> watchCategories();

  Future<Either<Failure, Unit>> saveCategory(Category category);

  Future<Either<Failure, Unit>> deleteCategory(UniqueId categoryUuid);
}

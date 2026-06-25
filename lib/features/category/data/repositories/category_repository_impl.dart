import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/category/data/datasources/category_local_data_source.dart';
import 'package:expense_tracker/features/category/data/models/category_model.dart';
import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/category/domain/repositories/category_repository.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._localDataSource);

  final CategoryLocalDataSource _localDataSource;

  @override
  Stream<Either<Failure, List<Category>>> watchCategories() {
    return _localDataSource.watchCategories().map(
          (models) => Right(
            models.map((m) => m.toEntity()).toList(),
          ),
        );
  }

  @override
  Future<Either<Failure, Unit>> saveCategory(Category category) async {
    try {
      if (category.parentUuid != null) {
        final parent = await _localDataSource.getCategoryByUuid(
          category.parentUuid!.getOrCrash(),
        );
        if (parent == null) {
          return const Left(
            Failure.localFailure(message: 'Parent category not found'),
          );
        }
      }

      await _localDataSource.saveCategory(CategoryModel.fromEntity(category));
      return const Right(unit);
    } catch (e) {
      return Left(Failure.localFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(UniqueId categoryUuid) async {
    try {
      await _localDataSource.deleteCategoryWithDescendants(
        categoryUuid.getOrCrash(),
      );
      return const Right(unit);
    } catch (e) {
      return Left(Failure.localFailure(message: e.toString()));
    }
  }
}

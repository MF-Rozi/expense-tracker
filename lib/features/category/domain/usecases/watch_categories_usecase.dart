import 'package:dartz/dartz.dart';
import 'package:template/core/domain/failures/failure.dart';
import 'package:template/core/domain/usecases/use_case.dart';
import 'package:template/features/category/domain/entities/category.dart';
import 'package:template/features/category/domain/repositories/category_repository.dart';

class WatchCategoriesUseCase extends StreamUseCase<List<Category>, NoParams> {
  const WatchCategoriesUseCase(this._repository);

  final CategoryRepository _repository;

  @override
  Stream<Either<Failure, List<Category>>> call(NoParams params) {
    return _repository.watchCategories();
  }
}

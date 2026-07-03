import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/domain/usecases/use_case.dart';
import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/category/domain/repositories/category_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class WatchCategoriesUseCase extends StreamUseCase<List<Category>, NoParams> {
  const WatchCategoriesUseCase(this._repository);

  final CategoryRepository _repository;

  @override
  Stream<Either<Failure, List<Category>>> call(NoParams params) {
    return _repository.watchCategories();
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/domain/usecases/use_case.dart';
import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/category/domain/repositories/category_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SaveCategoryUseCase extends UseCase<Unit, SaveCategoryParams> {
  const SaveCategoryUseCase(this._repository);

  final CategoryRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SaveCategoryParams params) {
    return _repository.saveCategory(params.category);
  }
}

class SaveCategoryParams extends Equatable {
  const SaveCategoryParams(this.category);

  final Category category;

  @override
  List<Object?> get props => [category];
}

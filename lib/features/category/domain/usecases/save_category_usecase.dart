import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:template/core/domain/failures/failure.dart';
import 'package:template/core/domain/usecases/use_case.dart';
import 'package:template/features/category/domain/entities/category.dart';
import 'package:template/features/category/domain/repositories/category_repository.dart';

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

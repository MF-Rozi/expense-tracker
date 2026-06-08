import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:template/core/domain/failures/failure.dart';
import 'package:template/core/domain/usecases/use_case.dart';
import 'package:template/features/category/domain/repositories/category_repository.dart';
import 'package:template/shared/domain/entities/value_objects.dart';

class DeleteCategoryUseCase extends UseCase<Unit, DeleteCategoryParams> {
  const DeleteCategoryUseCase(this._repository);

  final CategoryRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(DeleteCategoryParams params) {
    return _repository.deleteCategory(params.categoryUuid);
  }
}

class DeleteCategoryParams extends Equatable {
  const DeleteCategoryParams(this.categoryUuid);

  final UniqueId categoryUuid;

  @override
  List<Object?> get props => [categoryUuid];
}

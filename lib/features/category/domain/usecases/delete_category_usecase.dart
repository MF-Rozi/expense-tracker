import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/core/domain/usecases/use_case.dart';
import 'package:expense_tracker/features/category/domain/repositories/category_repository.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:injectable/injectable.dart';

@injectable
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

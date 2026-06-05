import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:template/core/domain/usecases/use_case.dart';
import 'package:template/features/category/domain/entities/category.dart';
import 'package:template/features/category/domain/usecases/delete_category_usecase.dart';
import 'package:template/features/category/domain/usecases/save_category_usecase.dart';
import 'package:template/features/category/domain/usecases/watch_categories_usecase.dart';
import 'package:template/features/category/presentation/blocs/category_state.dart';
import 'package:template/shared/domain/entities/value_objects.dart';

@lazySingleton
class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit(
    this._watchCategories,
    this._saveCategory,
    this._deleteCategory,
  ) : super(CategoryState.initial()) {
    _init();
  }

  final WatchCategoriesUseCase _watchCategories;
  final SaveCategoryUseCase _saveCategory;
  final DeleteCategoryUseCase _deleteCategory;

  StreamSubscription? _categoriesSubscription;

  void _init() {
    emit(state.copyWith(isLoading: true));
    _categoriesSubscription = _watchCategories(NoParams()).listen((result) {
      result.fold(
        (failure) => emit(state.copyWith(
          isLoading: false,
          error: failure.toString(),
        )),
        (categories) => emit(state.copyWith(
          isLoading: false,
          allCategories: categories,
          error: null,
        )),
      );
    });
  }

  void selectCategory(String uuid) {
    final newStack = List<String>.from(state.navigationStack)..add(uuid);
    emit(state.copyWith(navigationStack: newStack));
  }

  void goBack() {
    if (state.navigationStack.isNotEmpty) {
      final newStack = List<String>.from(state.navigationStack)..removeLast();
      emit(state.copyWith(navigationStack: newStack));
    }
  }

  Future<void> saveCategory(Category category) async {
    emit(state.copyWith(isLoading: true));
    final result = await _saveCategory(SaveCategoryParams(category));
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.toString(),
      )),
      (_) => emit(state.copyWith(isLoading: false)),
    );
  }

  Future<void> deleteCategory(String uuid) async {
    emit(state.copyWith(isLoading: true));
    final result = await _deleteCategory(
      DeleteCategoryParams(UniqueId(uuid)),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.toString(),
      )),
      (_) => emit(state.copyWith(isLoading: false)),
    );
  }

  @override
  Future<void> close() {
    _categoriesSubscription?.cancel();
    return super.close();
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:template/core/di/injector.dart';
import 'package:template/features/category/presentation/blocs/category_cubit.dart';
import 'package:template/features/category/presentation/pages/category_manage_page.dart';

class AppRouter extends Equatable {
  static const home = 'categories';

  @override
  List<Object?> get props => [home];
}

GoRouter router([String? initialLocation]) => GoRouter(
      debugLogDiagnostics: kDebugMode || kProfileMode,
      initialLocation: initialLocation ?? '/',
      routes: [
        GoRoute(
          path: '/',
          name: AppRouter.home,
          builder: (context, state) => BlocProvider<CategoryCubit>(
            create: (context) => getIt<CategoryCubit>(),
            child: const CategoryManagePage(),
          ),
        ),
      ],
    );

import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/category/presentation/pages/category_manage_page.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

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
          builder: (context, state) => const CategoryManagePage(),
        ),
      ],
    );

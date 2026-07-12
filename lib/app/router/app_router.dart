import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/category/presentation/pages/category_manage_page.dart';
import 'package:expense_tracker/features/transaction/presentation/blocs/transaction_cubit.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/presentation/pages/transaction_entry_page.dart';
import 'package:expense_tracker/features/transaction/presentation/pages/transaction_history_page.dart';
import 'package:expense_tracker/injector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter extends Equatable {
  static const home = 'home';

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
          builder: (context, state) {
            final transaction = state.extra as Transaction?;
            return BlocProvider(
              create: (context) => getIt<TransactionCubit>(),
              child: TransactionEntryPage(existingTransaction: transaction),
            );
          },
        ),
        GoRoute(
          path: '/categories',
          name: 'categories',
          builder: (context, state) => const CategoryManagePage(),
        ),
        GoRoute(
          path: '/transactions',
          name: 'transactions',
          builder: (context, state) => const TransactionHistoryPage(),
        ),
      ],
    );

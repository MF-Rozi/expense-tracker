import 'package:equatable/equatable.dart';
import 'package:expense_tracker/app/view/main_layout.dart';
import 'package:expense_tracker/features/category/presentation/pages/category_manage_page.dart';
import 'package:expense_tracker/features/counter/presentation/pages/counter_page.dart';
import 'package:expense_tracker/features/dashboard/presentation/blocs/dashboard_cubit.dart';
import 'package:expense_tracker/features/dashboard/presentation/pages/home_page.dart';
import 'package:expense_tracker/features/easter_egg/presentation/blocs/easter_egg_cubit.dart';
import 'package:expense_tracker/features/insights/presentation/blocs/insights_cubit.dart';
import 'package:expense_tracker/features/insights/presentation/pages/insights_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/settings_page.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/presentation/blocs/transaction_cubit.dart';
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

GoRouter router([
  String? initialLocation,
  bool Function()? isCounterUnlocked,
]) =>
    GoRouter(
      debugLogDiagnostics: kDebugMode || kProfileMode,
      initialLocation: initialLocation ?? '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => MainLayout(child: child),
          routes: [
            GoRoute(
              path: '/',
              name: AppRouter.home,
              builder: (context, state) => BlocProvider(
                create: (context) => getIt<DashboardCubit>(),
                child: const HomePage(),
              ),
            ),
            GoRoute(
              path: '/transactions',
              name: 'transactions',
              builder: (context, state) => const TransactionHistoryPage(),
            ),
            GoRoute(
              path: '/stats',
              name: 'stats',
              builder: (context, state) => BlocProvider(
                create: (context) => getIt<InsightsCubit>()..load(),
                child: const InsightsPage(),
              ),
            ),
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/transaction/new',
          name: 'transaction_new',
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
          path: '/counter',
          name: 'counter',
          // Locked users never reach the secret room — even via direct
          // navigation or a future deep link.
          redirect: (context, state) {
            final isUnlocked = (isCounterUnlocked ??
                    () => getIt<EasterEggCubit>().state.progress.unlocked)()
                ? null
                : '/settings';
            return isUnlocked;
          },
          builder: (context, state) => const CounterPage(),
        ),
      ],
    );

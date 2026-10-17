// Copyright (c) 2022, Adryan Eka Vandra
// https://github.com/adryanev/flutter-template-architecture-template
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/app/app.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_cubit.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_state.dart';
import 'package:expense_tracker/features/dashboard/presentation/blocs/dashboard_cubit.dart';
import 'package:expense_tracker/features/dashboard/presentation/blocs/dashboard_state.dart';
import 'package:expense_tracker/features/streak/domain/repositories/app_open_repository.dart';
import 'package:expense_tracker/injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/helpers.dart';

class MockCategoryCubit extends Mock implements CategoryCubit {}

class MockDashboardCubit extends Mock implements DashboardCubit {}

class MockAppOpenRepository extends Mock implements AppOpenRepository {}

void main() {
  late MockCategoryCubit mockCategoryCubit;
  late MockDashboardCubit mockDashboardCubit;
  late MockAppOpenRepository mockAppOpenRepo;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await configureInjector();

    mockCategoryCubit = MockCategoryCubit();
    when(() => mockCategoryCubit.state).thenReturn(CategoryState.initial());
    when(() => mockCategoryCubit.stream)
        .thenAnswer((_) => const Stream.empty());

    mockDashboardCubit = MockDashboardCubit();
    when(() => mockDashboardCubit.state).thenReturn(const DashboardState());
    when(() => mockDashboardCubit.stream)
        .thenAnswer((_) => const Stream.empty());
    when(
      () => mockDashboardCubit.loadDashboardData(
        showLoadingIndicator: any(named: 'showLoadingIndicator'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockDashboardCubit.close()).thenAnswer((_) async {});

    mockAppOpenRepo = MockAppOpenRepository();
    when(mockAppOpenRepo.recordOpen).thenAnswer((_) async => const Right(unit));

    getIt
      ..allowReassignment = true
      ..registerSingleton<CategoryCubit>(mockCategoryCubit)
      ..registerFactory<DashboardCubit>(() => mockDashboardCubit)
      ..registerSingleton<AppOpenRepository>(mockAppOpenRepo);
  });

  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);
  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpAppRouter(
        '/',
        (child) => BlocProvider<CategoryCubit>.value(
          value: getIt<CategoryCubit>(),
          child: child,
        ),
        isConnected: false,
      );
      expect(find.byType(MaterialApp, skipOffstage: false), findsOneWidget);
    });

    testWidgets('records app open event once on startup', (tester) async {
      when(mockAppOpenRepo.recordOpen)
          .thenAnswer((_) async => const Right(unit));

      await tester.pumpWidget(const App());
      await tester.pump();

      verify(mockAppOpenRepo.recordOpen).called(1);
    });
  });
}

import 'package:expense_tracker/features/category/presentation/blocs/category_cubit.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_state.dart';
import 'package:expense_tracker/features/category/presentation/pages/category_manage_page.dart';
import 'package:expense_tracker/features/easter_egg/presentation/blocs/easter_egg_cubit.dart';
import 'package:expense_tracker/injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/helpers.dart';

class MockCategoryCubit extends Mock implements CategoryCubit {}

class MockEasterEggCubit extends Mock implements EasterEggCubit {}

void main() {
  late MockCategoryCubit mockCategoryCubit;
  late MockEasterEggCubit mockEasterEggCubit;

  setUp(() {
    mockCategoryCubit = MockCategoryCubit();
    mockEasterEggCubit = MockEasterEggCubit();

    when(() => mockCategoryCubit.state).thenReturn(CategoryState.initial());
    when(() => mockCategoryCubit.stream)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockEasterEggCubit.onCategoriesOpened()).thenReturn(null);

    getIt
      ..allowReassignment = true
      ..registerSingleton<EasterEggCubit>(mockEasterEggCubit);
  });

  testWidgets(
      'renders SliverAppBar with non-overlapping titlePadding '
      'and solid background', (tester) async {
    await tester.pumpApp(
      BlocProvider<CategoryCubit>.value(
        value: mockCategoryCubit,
        child: const CategoryManagePage(),
      ),
    );

    final sliverAppBarFinder = find.byType(SliverAppBar);
    expect(sliverAppBarFinder, findsOneWidget);

    final sliverAppBar = tester.widget<SliverAppBar>(sliverAppBarFinder);
    expect(sliverAppBar.backgroundColor, const Color(0xFFF8F9FA));

    final flexibleSpace = sliverAppBar.flexibleSpace! as FlexibleSpaceBar;
    expect(
      flexibleSpace.titlePadding,
      const EdgeInsets.only(left: 56, right: 24, bottom: 16),
    );

    expect(find.text('Envelopes'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_config.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/presentation/blocs/streak_config_cubit.dart';
import 'package:expense_tracker/features/streak/presentation/blocs/streak_config_state.dart';
import 'package:expense_tracker/features/streak/presentation/widgets/streak_config_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

class MockStreakConfigCubit extends MockCubit<StreakConfigState>
    implements StreakConfigCubit {}

void main() {
  late MockStreakConfigCubit mockCubit;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    mockCubit = MockStreakConfigCubit();
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  Widget buildSheet({
    StreakType initialType = StreakType.tracking,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: StreakConfigSheet(
          initialType: initialType,
          cubit: mockCubit,
        ),
      ),
    );
  }

  group('StreakConfigSheet', () {
    testWidgets('opens at tracking section by default', (tester) async {
      when(() => mockCubit.state).thenReturn(
        const StreakConfigState(isLoading: false),
      );

      await tester.pumpWidget(buildSheet());

      expect(find.text('Streak Settings'), findsOneWidget);
      expect(find.text('Window Gap Allowance'), findsOneWidget);
      expect(find.text('Activation Threshold'), findsOneWidget);
      expect(find.byKey(const Key('window_value')), findsOneWidget);
      expect(find.text('3 days'), findsNWidgets(2)); // window & minimum
    });

    testWidgets(
      'opens at requested section when deep-linked to app-open',
      (tester) async {
        when(() => mockCubit.state).thenReturn(
          const StreakConfigState(
            isLoading: false,
            selectedType: StreakType.appOpen,
          ),
        );

        await tester.pumpWidget(
          buildSheet(initialType: StreakType.appOpen),
        );

        expect(find.text('Streak Settings'), findsOneWidget);
        expect(find.text('App-Open Cadence'), findsOneWidget);
        expect(find.text('Phase 2 Preview'), findsOneWidget);
        expect(find.byKey(const Key('cadence_preset_1')), findsOneWidget);
        expect(find.byKey(const Key('cadence_preset_7')), findsOneWidget);
        expect(find.text('Custom Cadence'), findsOneWidget);
      },
    );

    testWidgets(
      'opens at requested section when deep-linked to no-spend',
      (tester) async {
        when(() => mockCubit.state).thenReturn(
          const StreakConfigState(
            isLoading: false,
            selectedType: StreakType.noSpend,
          ),
        );

        await tester.pumpWidget(
          buildSheet(initialType: StreakType.noSpend),
        );

        expect(find.text('No-Spend Streak'), findsOneWidget);
        expect(find.text('Phase 2'), findsOneWidget);
        expect(find.text('Reserved Placeholder'), findsOneWidget);
      },
    );

    testWidgets(
      'opens at requested section when deep-linked to under-budget',
      (tester) async {
        when(() => mockCubit.state).thenReturn(
          const StreakConfigState(
            isLoading: false,
            selectedType: StreakType.underBudget,
          ),
        );

        await tester.pumpWidget(
          buildSheet(initialType: StreakType.underBudget),
        );

        expect(find.text('Under-Budget Streak'), findsOneWidget);
        expect(find.text('Phase 3'), findsOneWidget);
        expect(find.text('Reserved Placeholder'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping type chips invokes selectType on cubit',
      (tester) async {
        when(() => mockCubit.state).thenReturn(
          const StreakConfigState(isLoading: false),
        );

        await tester.pumpWidget(buildSheet());

        await tester.tap(
          find.byKey(const Key('streak_config_type_appOpen')),
        );
        verify(() => mockCubit.selectType(StreakType.appOpen)).called(1);

        await tester.tap(
          find.byKey(const Key('streak_config_type_noSpend')),
        );
        verify(() => mockCubit.selectType(StreakType.noSpend)).called(1);

        await tester.tap(
          find.byKey(const Key('streak_config_type_underBudget')),
        );
        verify(() => mockCubit.selectType(StreakType.underBudget)).called(1);
      },
    );

    testWidgets(
      'tracking steppers increment and decrement window and minimum',
      (tester) async {
        when(() => mockCubit.incrementWindow()).thenAnswer((_) async {});
        when(() => mockCubit.decrementWindow()).thenAnswer((_) async {});
        when(() => mockCubit.incrementMinimum()).thenAnswer((_) async {});
        when(() => mockCubit.decrementMinimum()).thenAnswer((_) async {});

        when(() => mockCubit.state).thenReturn(
          const StreakConfigState(isLoading: false),
        );

        await tester.pumpWidget(buildSheet());

        await tester.tap(find.byKey(const Key('window_increment')));
        verify(() => mockCubit.incrementWindow()).called(1);

        await tester.tap(find.byKey(const Key('window_decrement')));
        verify(() => mockCubit.decrementWindow()).called(1);

        await tester.tap(find.byKey(const Key('minimum_increment')));
        verify(() => mockCubit.incrementMinimum()).called(1);

        await tester.tap(find.byKey(const Key('minimum_decrement')));
        verify(() => mockCubit.decrementMinimum()).called(1);
      },
    );

    testWidgets(
      'stepper disables decrement when value is 1 (clamping gate)',
      (tester) async {
        when(() => mockCubit.state).thenReturn(
          const StreakConfigState(
            isLoading: false,
            config: StreakConfig(window: 1, minimum: 1),
          ),
        );

        await tester.pumpWidget(buildSheet());

        final windowDecr = tester.widget<IconButton>(
          find.byKey(const Key('window_decrement')),
        );
        expect(windowDecr.onPressed, isNull);

        final minDecr = tester.widget<IconButton>(
          find.byKey(const Key('minimum_decrement')),
        );
        expect(minDecr.onPressed, isNull);
      },
    );

    testWidgets(
      'app-open preset chips and custom stepper invoke updateCadence on cubit',
      (tester) async {
        when(() => mockCubit.updateCadence(any())).thenAnswer((_) async {});
        when(() => mockCubit.incrementCadence()).thenAnswer((_) async {});
        when(() => mockCubit.decrementCadence()).thenAnswer((_) async {});

        when(() => mockCubit.state).thenReturn(
          const StreakConfigState(
            isLoading: false,
            selectedType: StreakType.appOpen,
          ),
        );

        await tester.pumpWidget(buildSheet(initialType: StreakType.appOpen));

        await tester.tap(find.byKey(const Key('cadence_preset_1')));
        verify(() => mockCubit.updateCadence(1)).called(1);

        await tester.tap(find.byKey(const Key('cadence_preset_3')));
        verify(() => mockCubit.updateCadence(3)).called(1);

        await tester.tap(find.byKey(const Key('cadence_increment')));
        verify(() => mockCubit.incrementCadence()).called(1);

        await tester.tap(find.byKey(const Key('cadence_decrement')));
        verify(() => mockCubit.decrementCadence()).called(1);
      },
    );

    testWidgets(
      'shows loading indicator when isLoading is true',
      (tester) async {
        when(() => mockCubit.state).thenReturn(
          const StreakConfigState(),
        );

        await tester.pumpWidget(buildSheet());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets('close button pops the sheet', (tester) async {
      when(() => mockCubit.state).thenReturn(
        const StreakConfigState(isLoading: false),
      );

      var didPop = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  StreakConfigSheet.show(
                    context,
                    cubit: mockCubit,
                  ).then((_) {
                    didPop = true;
                  });
                },
                child: const Text('Open Sheet'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(StreakConfigSheet), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(StreakConfigSheet), findsNothing);
      expect(didPop, isTrue);
    });
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:expense_tracker/core/storages/local_storages.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_config.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/presentation/blocs/streak_config_cubit.dart';
import 'package:expense_tracker/features/streak/presentation/blocs/streak_config_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorage extends Mock implements LocalStorage {}

void main() {
  late MockLocalStorage mockStorage;
  late StreakConfigCubit cubit;

  setUp(() {
    mockStorage = MockLocalStorage();
    when(() => mockStorage.getStreakWindowDays())
        .thenAnswer((_) async => 3);
    when(() => mockStorage.getStreakMinimumDays())
        .thenAnswer((_) async => 3);
    when(() => mockStorage.getAppOpenCadenceDays())
        .thenAnswer((_) async => 7);
    when(() => mockStorage.setStreakWindowDays(any()))
        .thenAnswer((_) async {});
    when(() => mockStorage.setStreakMinimumDays(any()))
        .thenAnswer((_) async {});
    when(() => mockStorage.setAppOpenCadenceDays(any()))
        .thenAnswer((_) async {});

    cubit = StreakConfigCubit(mockStorage);
  });

  tearDown(() {
    cubit.close();
  });

  group('StreakConfigCubit', () {
    test('initial state has default config and loading true', () {
      expect(cubit.state, const StreakConfigState());
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.selectedType, StreakType.tracking);
    });

    blocTest<StreakConfigCubit, StreakConfigState>(
      'load reads from storage and selects initialType',
      build: () => cubit,
      act: (cubit) => cubit.load(initialType: StreakType.appOpen),
      expect: () => [
        const StreakConfigState(selectedType: StreakType.appOpen),
        const StreakConfigState(
          isLoading: false,
          selectedType: StreakType.appOpen,
        ),
      ],
      verify: (_) {
        verify(() => mockStorage.getStreakWindowDays()).called(1);
        verify(() => mockStorage.getStreakMinimumDays()).called(1);
        verify(() => mockStorage.getAppOpenCadenceDays()).called(1);
      },
    );

    blocTest<StreakConfigCubit, StreakConfigState>(
      'selectType changes active type without reloading storage',
      build: () => cubit,
      seed: () => const StreakConfigState(isLoading: false),
      act: (cubit) => cubit.selectType(StreakType.underBudget),
      expect: () => [
        const StreakConfigState(
          isLoading: false,
          selectedType: StreakType.underBudget,
        ),
      ],
    );

    group('window tuning', () {
      blocTest<StreakConfigCubit, StreakConfigState>(
        'updateWindow persists and emits updated state',
        build: () => cubit,
        seed: () => const StreakConfigState(isLoading: false),
        act: (cubit) => cubit.updateWindow(5),
        expect: () => [
          const StreakConfigState(
            isLoading: false,
            config: StreakConfig(window: 5),
          ),
        ],
        verify: (_) {
          verify(() => mockStorage.setStreakWindowDays(5)).called(1);
        },
      );

      blocTest<StreakConfigCubit, StreakConfigState>(
        'updateWindow clamps value < 1 to 1',
        build: () => cubit,
        seed: () => const StreakConfigState(isLoading: false),
        act: (cubit) => cubit.updateWindow(0),
        expect: () => [
          const StreakConfigState(
            isLoading: false,
            config: StreakConfig(window: 1),
          ),
        ],
        verify: (_) {
          verify(() => mockStorage.setStreakWindowDays(1)).called(1);
        },
      );

      blocTest<StreakConfigCubit, StreakConfigState>(
        'incrementWindow increases window by 1',
        build: () => cubit,
        seed: () => const StreakConfigState(isLoading: false),
        act: (cubit) => cubit.incrementWindow(),
        expect: () => [
          const StreakConfigState(
            isLoading: false,
            config: StreakConfig(window: 4),
          ),
        ],
        verify: (_) {
          verify(() => mockStorage.setStreakWindowDays(4)).called(1);
        },
      );

      blocTest<StreakConfigCubit, StreakConfigState>(
        'decrementWindow decreases window by 1',
        build: () => cubit,
        seed: () => const StreakConfigState(isLoading: false),
        act: (cubit) => cubit.decrementWindow(),
        expect: () => [
          const StreakConfigState(
            isLoading: false,
            config: StreakConfig(window: 2),
          ),
        ],
        verify: (_) {
          verify(() => mockStorage.setStreakWindowDays(2)).called(1);
        },
      );
    });

    group('minimum tuning', () {
      blocTest<StreakConfigCubit, StreakConfigState>(
        'updateMinimum persists and emits updated state',
        build: () => cubit,
        seed: () => const StreakConfigState(isLoading: false),
        act: (cubit) => cubit.updateMinimum(6),
        expect: () => [
          const StreakConfigState(
            isLoading: false,
            config: StreakConfig(minimum: 6),
          ),
        ],
        verify: (_) {
          verify(() => mockStorage.setStreakMinimumDays(6)).called(1);
        },
      );

      blocTest<StreakConfigCubit, StreakConfigState>(
        'updateMinimum clamps value < 1 to 1',
        build: () => cubit,
        seed: () => const StreakConfigState(isLoading: false),
        act: (cubit) => cubit.updateMinimum(-5),
        expect: () => [
          const StreakConfigState(
            isLoading: false,
            config: StreakConfig(minimum: 1),
          ),
        ],
        verify: (_) {
          verify(() => mockStorage.setStreakMinimumDays(1)).called(1);
        },
      );

      blocTest<StreakConfigCubit, StreakConfigState>(
        'incrementMinimum increases minimum by 1',
        build: () => cubit,
        seed: () => const StreakConfigState(isLoading: false),
        act: (cubit) => cubit.incrementMinimum(),
        expect: () => [
          const StreakConfigState(
            isLoading: false,
            config: StreakConfig(minimum: 4),
          ),
        ],
        verify: (_) {
          verify(() => mockStorage.setStreakMinimumDays(4)).called(1);
        },
      );

      blocTest<StreakConfigCubit, StreakConfigState>(
        'decrementMinimum decreases minimum by 1',
        build: () => cubit,
        seed: () => const StreakConfigState(isLoading: false),
        act: (cubit) => cubit.decrementMinimum(),
        expect: () => [
          const StreakConfigState(
            isLoading: false,
            config: StreakConfig(minimum: 2),
          ),
        ],
        verify: (_) {
          verify(() => mockStorage.setStreakMinimumDays(2)).called(1);
        },
      );
    });

    group('cadence tuning', () {
      blocTest<StreakConfigCubit, StreakConfigState>(
        'updateCadence persists and emits updated state',
        build: () => cubit,
        seed: () => const StreakConfigState(isLoading: false),
        act: (cubit) => cubit.updateCadence(2),
        expect: () => [
          const StreakConfigState(
            isLoading: false,
            config: StreakConfig(cadence: 2),
          ),
        ],
        verify: (_) {
          verify(() => mockStorage.setAppOpenCadenceDays(2)).called(1);
        },
      );

      blocTest<StreakConfigCubit, StreakConfigState>(
        'updateCadence clamps value < 1 to 1',
        build: () => cubit,
        seed: () => const StreakConfigState(isLoading: false),
        act: (cubit) => cubit.updateCadence(0),
        expect: () => [
          const StreakConfigState(
            isLoading: false,
            config: StreakConfig(cadence: 1),
          ),
        ],
        verify: (_) {
          verify(() => mockStorage.setAppOpenCadenceDays(1)).called(1);
        },
      );

      blocTest<StreakConfigCubit, StreakConfigState>(
        'incrementCadence increases cadence by 1',
        build: () => cubit,
        seed: () => const StreakConfigState(isLoading: false),
        act: (cubit) => cubit.incrementCadence(),
        expect: () => [
          const StreakConfigState(
            isLoading: false,
            config: StreakConfig(cadence: 8),
          ),
        ],
        verify: (_) {
          verify(() => mockStorage.setAppOpenCadenceDays(8)).called(1);
        },
      );

      blocTest<StreakConfigCubit, StreakConfigState>(
        'decrementCadence decreases cadence by 1',
        build: () => cubit,
        seed: () => const StreakConfigState(isLoading: false),
        act: (cubit) => cubit.decrementCadence(),
        expect: () => [
          const StreakConfigState(
            isLoading: false,
            config: StreakConfig(cadence: 6),
          ),
        ],
        verify: (_) {
          verify(() => mockStorage.setAppOpenCadenceDays(6)).called(1);
        },
      );
    });
  });
}

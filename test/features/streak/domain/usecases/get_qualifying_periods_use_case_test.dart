import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_period.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/domain/repositories/streak_repository.dart';
import 'package:expense_tracker/features/streak/domain/usecases/get_qualifying_periods_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStreakRepository extends Mock implements StreakRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(StreakType.tracking);
  });

  late MockStreakRepository mockRepository;
  late GetQualifyingPeriodsUseCase useCase;

  setUp(() {
    mockRepository = MockStreakRepository();
    useCase = GetQualifyingPeriodsUseCase(mockRepository);
  });

  final tPeriods = [
    StreakDay.fromDateTime(DateTime(2026, 4)),
    StreakDay.fromDateTime(DateTime(2026, 4, 2)),
    StreakDay.fromDateTime(DateTime(2026, 4, 3)),
  ];

  group('GetQualifyingPeriodsUseCase', () {
    test('delegates parameters to repository and returns list of periods',
        () async {
      final start = DateTime(2026, 4);
      final end = DateTime(2026, 4, 30);
      final params = GetQualifyingPeriodsParams(
        startDate: start,
        endDate: end,
      );

      when(
        () => mockRepository.getQualifyingPeriods(
          type: any(named: 'type'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => Right(tPeriods));

      final result = await useCase(params);

      expect(result, Right<Failure, List<StreakPeriod>>(tPeriods));
      verify(
        () => mockRepository.getQualifyingPeriods(
          startDate: start,
          endDate: end,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('propagates Failure from repository', () async {
      const failure = Failure.localFailure(message: 'Error fetching periods');
      when(
        () => mockRepository.getQualifyingPeriods(
          type: any(named: 'type'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(const GetQualifyingPeriodsParams());

      expect(result, const Left<Failure, List<StreakPeriod>>(failure));
    });

    test('GetQualifyingPeriodsParams supports equality comparison', () {
      final start = DateTime(2026, 4);
      final p1 = GetQualifyingPeriodsParams(startDate: start);
      final p2 = GetQualifyingPeriodsParams(startDate: start);
      const p3 = GetQualifyingPeriodsParams(type: StreakType.appOpen);

      expect(p1, equals(p2));
      expect(p1, isNot(equals(p3)));
    });
  });
}

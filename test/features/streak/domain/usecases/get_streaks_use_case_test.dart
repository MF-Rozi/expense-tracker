import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_status.dart';
import 'package:expense_tracker/features/streak/domain/entities/streak_type.dart';
import 'package:expense_tracker/features/streak/domain/repositories/streak_repository.dart';
import 'package:expense_tracker/features/streak/domain/usecases/get_streaks_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStreakRepository extends Mock implements StreakRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(StreakType.tracking);
  });

  late MockStreakRepository mockRepository;
  late GetStreaksUseCase useCase;

  setUp(() {
    mockRepository = MockStreakRepository();
    useCase = GetStreaksUseCase(mockRepository);
  });

  const tStreak = Streak(
    type: StreakType.tracking,
    length: 5,
    status: StreakStatus.active,
    daysUntilBreak: 3,
    nextMilestone: 7,
    consistencyRate: 0.8,
    bestLength: 5,
  );

  group('GetStreaksUseCase', () {
    test(
        'should delegate parameter passing to repository and return the streak',
        () async {
      final refDate = DateTime(2026, 9, 28);
      final params = GetStreaksParams(
        referenceDate: refDate,
      );

      when(
        () => mockRepository.getStreak(
          type: any(named: 'type'),
          referenceDate: any(named: 'referenceDate'),
        ),
      ).thenAnswer((_) async => const Right(tStreak));

      final result = await useCase(params);

      expect(result, const Right<Failure, Streak>(tStreak));
      verify(
        () => mockRepository.getStreak(
          referenceDate: refDate,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate Failure from repository', () async {
      const failure = Failure.localFailure(message: 'Error fetching streak');
      when(
        () => mockRepository.getStreak(
          type: any(named: 'type'),
          referenceDate: any(named: 'referenceDate'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(const GetStreaksParams());

      expect(result, const Left<Failure, Streak>(failure));
    });

    test('GetStreaksParams supports equality comparison', () {
      final date = DateTime(2026, 9, 28);
      final p1 = GetStreaksParams(referenceDate: date);
      final p2 = GetStreaksParams(referenceDate: date);
      const p3 = GetStreaksParams(type: StreakType.appOpen);

      expect(p1, equals(p2));
      expect(p1, isNot(equals(p3)));
    });
  });
}

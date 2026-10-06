import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/failure.dart';
import 'package:expense_tracker/features/streak/data/datasources/app_open_local_data_source.dart';
import 'package:expense_tracker/features/streak/data/models/app_open_model.dart';
import 'package:expense_tracker/features/streak/data/repositories/app_open_repository_impl.dart';
import 'package:expense_tracker/features/streak/domain/entities/app_open.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppOpenLocalDataSource extends Mock
    implements AppOpenLocalDataSource {}

void main() {
  late MockAppOpenLocalDataSource mockDataSource;
  late AppOpenRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockAppOpenLocalDataSource();
    repository = AppOpenRepositoryImpl(mockDataSource);
  });

  group('AppOpenRepositoryImpl.recordOpen', () {
    test('delegates to local data source and returns Right(unit)', () async {
      final openDate = DateTime(2026, 9, 26, 8, 30);
      when(
        () => mockDataSource.recordOpen(
          date: any(named: 'date'),
          uuid: any(named: 'uuid'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.recordOpen(
        date: openDate,
        uuid: 'test-uuid',
      );

      expect(result, equals(const Right<Failure, Unit>(unit)));
      verify(
        () => mockDataSource.recordOpen(
          date: openDate,
          uuid: 'test-uuid',
        ),
      ).called(1);
    });

    test(
        'multiple opens on same day persist as separate calls to datasource',
        () async {
      when(
        () => mockDataSource.recordOpen(
          date: any(named: 'date'),
          uuid: any(named: 'uuid'),
        ),
      ).thenAnswer((_) async {});

      final morning = DateTime(2026, 9, 26, 9);
      final evening = DateTime(2026, 9, 26, 21);

      await repository.recordOpen(date: morning, uuid: 'uuid-1');
      await repository.recordOpen(date: evening, uuid: 'uuid-2');

      verify(
        () => mockDataSource.recordOpen(
          date: morning,
          uuid: 'uuid-1',
        ),
      ).called(1);
      verify(
        () => mockDataSource.recordOpen(
          date: evening,
          uuid: 'uuid-2',
        ),
      ).called(1);
    });

    test('returns Left(Failure.localFailure) when datasource throws', () async {
      when(
        () => mockDataSource.recordOpen(
          date: any(named: 'date'),
          uuid: any(named: 'uuid'),
        ),
      ).thenThrow(Exception('database error'));

      final result = await repository.recordOpen();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('AppOpenRepositoryImpl.getOpenDates', () {
    test('returns sorted date list from local data source in date order',
        () async {
      final sortedDates = [
        DateTime(2026, 9, 20),
        DateTime(2026, 9, 22),
        DateTime(2026, 9, 25),
      ];
      final start = DateTime(2026, 9);
      final end = DateTime(2026, 9, 30);

      when(
        () => mockDataSource.getOpenDates(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => sortedDates);

      final result = await repository.getOpenDates(
        startDate: start,
        endDate: end,
      );

      expect(result.isRight(), isTrue);
      expect(
        result.getOrElse(() => fail('expected Right')),
        equals(sortedDates),
      );
      verify(
        () => mockDataSource.getOpenDates(
          startDate: start,
          endDate: end,
        ),
      ).called(1);
    });

    test('returns Left(Failure.localFailure) when datasource throws', () async {
      when(
        () => mockDataSource.getOpenDates(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenThrow(Exception('read failure'));

      final result = await repository.getOpenDates();

      expect(result.isLeft(), isTrue);
    });
  });

  group('AppOpenRepositoryImpl.getAppOpens', () {
    test('maps models to domain AppOpen entities', () async {
      final models = [
        AppOpenModel.create(
          uuid: 'id-1',
          date: DateTime(2026, 9, 20),
        ),
        AppOpenModel.create(
          uuid: 'id-2',
          date: DateTime(2026, 9, 21),
        ),
      ];

      when(
        () => mockDataSource.getAppOpens(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => models);

      final result = await repository.getAppOpens();

      expect(result.isRight(), isTrue);
      expect(
        result.getOrElse(() => fail('expected Right')),
        equals([
          AppOpen(uuid: 'id-1', date: DateTime(2026, 9, 20)),
          AppOpen(uuid: 'id-2', date: DateTime(2026, 9, 21)),
        ]),
      );
    });

    test('returns Left(Failure.localFailure) when datasource throws', () async {
      when(
        () => mockDataSource.getAppOpens(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenThrow(Exception('fetch error'));

      final result = await repository.getAppOpens();

      expect(result.isLeft(), isTrue);
    });
  });
}

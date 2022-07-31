import 'package:expense_tracker/features/logging/domain/entities/log.dart';
import 'package:expense_tracker/shared/categories/domain/entities/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Log Entity', () {
    test(
      'should instantiate log object',
      () async {
        // arrange

        // act
        final log = Log(
          id: UniqueId.generate(),
          action: 'log in user',
          path: 'auth/login',
          params: {},
          status: LogStatus.initiated,
        );
        // assert
        expect(log, isA<Log>());
      },
    );
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:expense_tracker/features/logging/presentation/bloc/logging_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Logging Bloc', () {
    blocTest<LoggingBloc, LoggingState>(
      'should emit [] when initiated',
      build: LoggingBloc.new,
      expect: () => <LoggingState>[],
    );
  });
}

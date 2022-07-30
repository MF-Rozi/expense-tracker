import 'package:bloc_test/bloc_test.dart';
import 'package:expense_tracker/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Splash Bloc', () {
    blocTest<SplashBloc, SplashState>(
      'emits [] when nothing added.',
      build: SplashBloc.new,
      expect: () => <SplashState>[],
    );
  });
}

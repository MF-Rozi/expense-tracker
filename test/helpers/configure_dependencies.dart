part of 'helpers.dart';

Future<void> configureInjector() async {
  await configureDependencies(environment: Environment.test);
}

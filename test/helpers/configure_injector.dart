import 'package:expense_tracker/core/utils/constants.dart';
import 'package:expense_tracker/injector.dart';

Future<void> configureInjector() async {
  await configureDependencies(environment: Environment.test);
}

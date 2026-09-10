import 'package:expense_tracker/core/utils/constants.dart';
import 'package:expense_tracker/injector.dart';

/// Configures the app-wide GetIt instance for tests.
///
/// `very_good test --optimization` (used by CI) merges every test file
/// into a single process, where `GetIt.init` therefore runs once per
/// suite on the shared instance. Enable reassignment so the duplicate
/// registrations replace instead of throwing, and each suite starts
/// from the canonical generated registrations.
Future<void> configureInjector() async {
  getIt.allowReassignment = true;
  await configureDependencies(environment: Environment.test);
}

import 'package:expense_tracker/injector.dart';
import 'package:expense_tracker/shared/flash/presentation/blocs/cubit/flash_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/helpers.dart';

void main() {
  test('FlashCubit is registered as a singleton across resolutions', () async {
    // Guards the wiring regression where a factory registration gave the
    // app-shell listener and feature cubits (e.g. the easter egg) separate
    // instances, silently dropping every displayed flash.
    SharedPreferences.setMockInitialValues({});
    await configureInjector();

    expect(getIt<FlashCubit>(), same(getIt<FlashCubit>()));
  });
}

import 'package:expense_tracker/features/easter_egg/data/datasources/easter_egg_storage.dart';
import 'package:expense_tracker/features/easter_egg/presentation/blocs/easter_egg_cubit.dart';
import 'package:expense_tracker/shared/flash/presentation/blocs/cubit/flash_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Flash bus fake that records displayed messages instead of emitting
/// state — lets suites assert which flashes fired without UI wiring.
class RecordingFlashCubit extends FlashCubit {
  final List<String> messages = [];

  @override
  Future<void> displayFlash(String message) async {
    messages.add(message);
  }
}

/// Builds a real [EasterEggCubit] backed by mock SharedPreferences.
///
/// With no [preferences] given, fresh mock storage is created; pass one
/// explicitly to share state across cubit instances (restore tests).
Future<EasterEggCubit> buildEggCubit({
  SharedPreferences? preferences,
  RecordingFlashCubit? flashCubit,
}) async {
  final effectivePreferences = preferences ?? await mockPreferences();
  return EasterEggCubit(
    EasterEggStorageImpl(effectivePreferences),
    flashCubit ?? RecordingFlashCubit(),
  );
}

Future<SharedPreferences> mockPreferences() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

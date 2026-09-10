import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

part 'flash_state.dart';

/// App-wide one-shot message bus. Must be a singleton: the app shell
/// listens to the instance provided at the root, so feature cubits that
/// display flashes (e.g. the easter egg) must resolve the same instance.
@lazySingleton
class FlashCubit extends Cubit<FlashState> {
  FlashCubit() : super(const FlashState.disappeared());

  Future<void> displayFlash(String message) async {
    emit(FlashState.appeared(message));
    emit(const FlashState.disappeared());
  }
}

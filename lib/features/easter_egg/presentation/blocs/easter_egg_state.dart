part of 'easter_egg_cubit.dart';

class EasterEggState extends Equatable {
  const EasterEggState({
    this.progress = const EasterEggProgress(),
    this.justRevealedHint = false,
  });

  final EasterEggProgress progress;

  /// True only on the frame where the hint is first revealed, so the
  /// Settings page can show the ritual dialog exactly once.
  final bool justRevealedHint;

  @override
  List<Object?> get props => [progress, justRevealedHint];
}

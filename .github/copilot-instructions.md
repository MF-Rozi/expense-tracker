# Copilot Instructions for Expense Tracker

This repository is a Flutter app built around strict clean architecture and a local-first expense-tracking product vision.

## Build, test, and lint

Use the Makefile targets when possible:

```sh
make get        # flutter pub get
make build      # build_runner generation
make watch      # build_runner watch
make test       # flutter test --coverage --test-randomize-ordering-seed random
make analyze    # dart analyze lib test
make format     # dart format --set-exit-if-changed lib test
make fix        # dart fix --apply
make check-fix  # dart fix --dry-run
make prepare    # fix + format + analyze
```

For a single test file, run:

```sh
flutter test test/features/counter/presentation/pages/counter_page_test.dart
```

Flavor runs:

```sh
flutter run --flavor development --target lib/main_development.dart
flutter run --flavor staging --target lib/main_staging.dart
flutter run --flavor production --target lib/main_production.dart
```

## High-level architecture

- `lib/bootstrap.dart` wires startup: dependency injection, Flutter error handling, and the global `BlocObserver`.
- `lib/app/view/app.dart` is the app shell: global bloc providers/listeners, `ScreenUtilInit`, localization, theming, and `MaterialApp.router`.
- `lib/app/router/app_router.dart` owns route definitions.
- `lib/injector.dart` and `lib/core/di/*` use `injectable` + `get_it` for dependency injection.
- Feature code follows `domain/`, `data/`, and `presentation/` split under `lib/features/<feature>/`.
- Shared cross-cutting code lives in `lib/core/` and `lib/shared/`.
- The intended product scope is the local-first finance app described in `README.md` / `documents/mindmap.mmd`: dashboard, transactions, analytics, settings, sync, and auth.

## Key conventions

- Keep generated code checked in, but do not edit it by hand: `lib/injector.config.dart`, `lib/gen/**`, `lib/l10n/arb/*.dart`, and analyzer-excluded `*.g.dart` / `*.freezed.dart` / `*.gen.dart` / `*.config.dart` files.
- Regenerate code with `build_runner` after changing injectable setup or other generated inputs.
- Tests mirror the `lib/` structure and commonly use helpers in `test/helpers/` such as `pump_app.dart` and `configure_injector.dart`.
- Use the app localization extension from `lib/l10n/l10n.dart` (`context.l10n`) instead of reaching for generated localization classes directly.
- The app uses `flutter_bloc` heavily; UI often reads state with `context.select` and dispatches actions through cubits/blocs.
- A global `ScaffoldMessengerKey` lives in `lib/core/utils/constants.dart` and is used for app-wide snackbars.
- Keep flavor entrypoints aligned with `Environment.development`, `Environment.staging`, and `Environment.production`.

# Expense Tracker

Expense Tracker is a Flutter app for recording daily income/expenses, monitoring spending habits, and reviewing financial trends.

![coverage][coverage_badge]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

## Project Status

This repository is currently using a clean-architecture Flutter foundation and still includes starter feature code (`counter`) while Expense Tracker features are being built.

## Product Scope

Based on the project documentation (`documents/mindmap.mmd`), the app scope includes:

- **Dashboard**
  - Total balance
  - Daily logging streak
  - Recent transactions
  - Quick-add transaction button
- **Transactions**
  - Add, edit, and delete transactions
  - Amount input
  - Category/date picker
  - Optional notes
- **Analytics**
  - Category pie chart
  - Daily/weekly bar chart
  - Time-based filtering
- **Settings**
  - Manage categories and icons
  - Currency selection
  - Data export

## Architecture

The project follows a clean architecture structure:

- **Presentation layer**: Flutter UI + `flutter_bloc`
- **Domain layer**: entities, repository contracts, and use cases
- **Data layer**: models and repository implementations

Current app modules are organized under:

- `lib/app` for app bootstrapping and routing
- `lib/core` for shared architecture components
- `lib/features` for feature modules
- `lib/shared` for reusable models/widgets/services

## Tech Stack

- Flutter + Dart (SDK `>=3.6.0 <4.0.0`)
- State management: `bloc`, `flutter_bloc`
- Navigation: `go_router`
- Dependency injection: `get_it`, `injectable`
- Local persistence utilities: `shared_preferences`
- Tooling: `build_runner`, `flutter_gen_runner`

## Getting Started

### 1) Install dependencies

```sh
flutter pub get
```

### 2) Run by flavor

```sh
# Development
flutter run --flavor development --target lib/main_development.dart

# Staging
flutter run --flavor staging --target lib/main_staging.dart

# Production
flutter run --flavor production --target lib/main_production.dart
```

## Development Commands

You can use [Makefile][makefile_link] shortcuts:

```sh
# analyze
make analyze

# run tests with coverage
make test

# run build_runner once
make build

# auto-fix and format/check
make fix
make check-fix
```

## Testing

```sh
flutter test --coverage --test-randomize-ordering-seed random
```

[coverage_badge]: coverage_badge.svg
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[makefile_link]: Makefile

# Expense Tracker

**_A Flutter Expense Tracking Application_**

Expense Tracker is designed as a **local-first personal finance app** for tracking transactions, analyzing spending behavior, and securely syncing user data.

![coverage][coverage_badge]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

---

## Product Scope

Based on `documents/mindmap.mmd`, the **final product** includes:

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

---

## Sync Engine 🔄

- **Local-first**
  - Isar Database
  - Instant UI updates
  - UUID generation
- **Cloud backup**
  - Firebase Firestore
  - Background sync logic
- **Authentication**
  - Google Sign-In
  - User data isolation

---

## Architecture

The app follows a clean architecture structure:

- **Presentation layer**: Flutter UI + `flutter_bloc`
- **Domain layer**: entities, repository contracts, and use cases
- **Data layer**: models and repository implementations

---

## Tech Stack

- Flutter + Dart
- `flutter_bloc` for state management
- Clean Architecture pattern
- Isar (local database)
- Firebase Firestore (cloud backup/sync)
- Google Sign-In (authentication)

---

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

---

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

---

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

---
title: Use FVM for Flutter validation
date: 2026-06-03
category: docs/solutions/tooling-decisions
module: expense-tracker
problem_type: tooling_decision
component: tooling
severity: medium
tags:
  - fvm
  - flutter
  - dart
  - validation
---

# Use FVM for Flutter validation

## Context

The repo’s Flutter tooling is managed through FVM, but the system `dart` binary was not available and the pinned local SDK was too old to resolve dependencies cleanly against the current analyzer constraint.

## Guidance

Use the project-managed Flutter SDK through FVM for analysis and tests. In this repo, the validation path that worked was:

```sh
fvm flutter analyze --no-pub lib test
fvm flutter test --no-pub --coverage --test-randomize-ordering-seed random
```

When pub resolution fails because the selected SDK is behind a package constraint, switch the project to a newer FVM-managed stable release and rerun the command through FVM rather than the system toolchain.

## Why This Matters

It keeps validation aligned with the repo’s pinned SDK instead of whichever Dart/Flutter binaries happen to be installed on the machine. That avoids false failures from local environment drift and makes dependency resolution repeatable for future sessions.

## When to Apply

- When `dart` is not on `PATH`
- When `flutter pub` or `flutter test` fails because the local SDK is older than a dependency constraint
- When you need reproducible validation in this repo

## Examples

```sh
fvm flutter analyze --no-pub lib test
fvm flutter test --no-pub --coverage --test-randomize-ordering-seed random
```

If dependency resolution fails under the current FVM SDK, update the project to a newer stable FVM release and retry the commands through `fvm flutter`.

# feat: Transaction Domain and Data Layers

**Status:** Active
**Date:** 2026-06-08
**Origin:** (see user request)

## Summary
Architectural blueprint for the Transaction Module's Domain and Data layers, focusing on DDD principles, Isar persistence, and strict data integrity. This plan covers the core Transaction entity, its value objects, Isar model mappings, and reactive repository implementation.

---

## Problem Frame
The application requires a robust way to record, persist, and track financial transactions. These transactions must be linked to a Category and maintain chronological order. Data integrity (e.g., non-negative amounts, existing categories) is paramount.

---

## Key Technical Decisions
- **DDD Value Objects:** Use `UniqueId` and `StringSingleLine` from `shared`. Create a new `Amount` value object to enforce non-negative constraints.
- **Functional Error Handling:** Use `Dartz` (`Either<Failure, T>`) for all domain and repository boundaries.
- **Isar Persistence:** Use `isar_community` for local storage with strategic indexing on `date` and `categoryUuid` for performance.
- **Reactive Architecture:** Repositories return `Stream<Either<Failure, List<Transaction>>>` to allow real-time UI updates.
- **Integrity Gating:** Implement a cross-module check in the repository to ensure transactions are only saved against existing categories.

---

## Implementation Units

### U5.1. Transaction Domain Layer
**Goal:** Define the core Transaction entity, Value Objects, and Use Cases.

**Files:**
- `lib/features/transaction/domain/entities/transaction.dart`
- `lib/features/transaction/domain/entities/transaction_type.dart`
- `lib/shared/domain/entities/value_objects.dart` (Add `Amount`)
- `lib/features/transaction/domain/usecases/save_transaction_use_case.dart`
- `lib/features/transaction/domain/usecases/delete_transaction_use_case.dart`
- `lib/features/transaction/domain/usecases/watch_transactions_use_case.dart`

**Approach:**
- **Amount Value Object:** Create `Amount` in `shared/domain/entities/value_objects.dart`. It should validate that the `double` input is >= 0.
- **Transaction Entity:** Implement `Transaction` extending `Equatable`. Properties: `uuid`, `amount`, `description`, `date`, `categoryUuid`, `type`, `note`.
- **TransactionType Enum:** `expense`, `income`, `investment`.
- **Use Cases:**
    - `SaveTransactionUseCase`: Extends `UseCase<Unit, Transaction>`.
    - `DeleteTransactionUseCase`: Extends `UseCase<Unit, UniqueId>`.
    - `WatchTransactionsUseCase`: Extends `StreamUseCase<List<Transaction>, NoParams>`.

**Test Scenarios:**
- **Amount VO:**
    - Valid: 100.0, 0.0.
    - Invalid: -1.0 (returns `ValueFailure.notInRange` or similar).
- **Transaction Entity:**
    - Verify equality and property assignment.
- **Use Cases:**
    - Mock repository and verify interaction.

---

### U5.2. Transaction Data Layer (Isar Model)
**Goal:** Map the Transaction entity to an Isar-compatible model.

**Files:**
- `lib/features/transaction/data/models/transaction_model.dart`

**Approach:**
- Use `@collection` annotation.
- `id` as `Id = Isar.autoIncrement`.
- `@Index(unique: true, replace: true)` on `uuid`.
- `@Index()` on `date` for chronological sorting.
- `@Index()` on `categoryUuid` for category-based filtering.
- Implement `toEntity()` and `factory fromEntity(Transaction)`.
- Ensure all fields (`uuid`, `amount`, `description`, `date`, `categoryUuid`, `type`, `note`) are mapped.

**Test Scenarios:**
- **Mapping:** Verify `fromEntity -> toEntity` roundtrip preserves all data and validates correctness of `UniqueId` and `Amount` reconstruction.

---

### U5.3. Local Data Source & Repository Implementation
**Goal:** Implement persistence logic and domain-to-data mapping.

**Files:**
- `lib/features/transaction/data/datasources/transaction_local_data_source.dart`
- `lib/features/transaction/domain/repositories/transaction_repository.dart`
- `lib/features/transaction/data/repositories/transaction_repository_impl.dart`

**Approach:**
- **Local Data Source:**
    - `watchTransactions()`: Returns `Stream<List<TransactionModel>>` sorted by `date` descending.
    - `saveTransaction(TransactionModel)`: standard Isar `put`.
    - `deleteTransaction(String uuid)`: filtered delete.
- **Repository Implementation:**
    - Implement `TransactionRepository` using `TransactionLocalDataSource` and `CategoryLocalDataSource`.
    - **Crucial Integrity Rule:** In `saveTransaction`, first call `categoryDataSource.getCategoryByUuid(entity.categoryUuid.getOrCrash())`. If null, return `Left(Failure.localFailure(message: "Referenced category structure does not exist."))`.
    - Wrap all calls in `Either<Failure, T>`.

**Test Scenarios:**
- **Save Integrity:**
    - Success when category exists.
    - Failure when category is missing.
- **Reactive Stream:**
    - Verify `watchTransactions` emits updates when data changes in Isar.

---

## Extra Presentation & Habit-Forming Requirements

### 1. Arithmetic Expression Evaluator Interface
**Goal:** Outline the interface for inline calculations in the presentation layer.

- **Interface:** `ArithmeticEvaluator`
- **Method:** `double? evaluate(String input)`
- **Behavior:**
    - Handles basic operators: `+`, `-`, `*`, `/`.
    - Sanitizes input (removes non-numeric/non-operator characters).
    - Used by the Cubit/Bloc to update the `Amount` field before entity creation.
    - Implementation suggestion: Use a simple recursive descent parser or a lightweight library like `expressions`.

### 2. Financial Streak Tracking Hook
**Goal:** Outline the mechanism for updating user streaks upon transaction persistence.

- **Mechanism:** `StreakTracker` hook.
- **Integration:** The `TransactionRepositoryImpl` or a dedicated `StreakUseCase` (decorating `SaveTransaction`) should:
    1. Check if the current transaction is the first of the day.
    2. Compare the date with the last recorded transaction date.
    3. Update a `StreakState` model (stored in `SharedPreferences` or Isar) if the consecutive day condition is met.
    4. Recalculate completion rate metrics.

---

## System-Wide Impact
- **Data Integrity:** Ensures no "orphan" transactions exist without categories.
- **Performance:** Strategic Isar indices ensure fast lookups even as the transaction volume grows.
- **Scalability:** Clean architecture separation allows for easy migration to a remote API in the future.

---

## Risks & Dependencies
- **Isar Code Generation:** Requires `build_runner` to be executed after model changes.
- **Category Dependency:** Transaction module depends on the `Category` module's existence check.

---

## Sources & Research
- `lib/features/category/`: Reference implementation for entities and models.
- `lib/core/domain/`: Base classes for clean architecture.
- `isar_community` documentation for indexing and streaming.

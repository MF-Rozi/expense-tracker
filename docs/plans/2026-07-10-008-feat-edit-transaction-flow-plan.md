---
title: "feat: Implement Edit Transaction Flow"
type: feat
status: active
date: 2026-07-10
---

# feat: Implement Edit Transaction Flow

## Summary
Architectural blueprint and plan for implementing the "Edit Transaction" flow. This involves making history cards clickable, passing the transaction data to the Transaction Entry page, loading the transaction into the form state, and executing the appropriate update query.

---

## Problem Frame
Users need the ability to edit existing transactions when they make a mistake or need to update transaction details. We will reuse the existing `TransactionEntryPage` to handle both new transaction creation and editing an existing transaction to keep the UI consistent and codebase DRY.

---

## Requirements

### Domain & Data Layer
- **R1.** Add `updateTransaction(Transaction transaction)` to the `TransactionRepository` interface.
- **R2.** Implement `updateTransaction` in `TransactionRepositoryImpl` to check category integrity and delegate to the local data source.
- **R3.** Add `updateTransaction(TransactionModel transaction)` to `TransactionLocalDataSource` interface and implement it in `IsarTransactionLocalDataSource` using `isar.writeTxn()` and `isar.transactionModels.put()`, ensuring `await transaction.category.save()` is executed.
- **R4.** Explicitly map and preserve the internal Isar auto-increment `id` when performing an update.

### State Management
- **R5.** Add `existingTransactionId` (as `UniqueId?`) to `TransactionState`.
- **R6.** Introduce `CreateTransactionUseCase` and `UpdateTransactionUseCase` to replace the single generic `SaveTransactionUseCase` for granular execution of transaction operations.
- **R7.** Add `loadExistingTransaction(Transaction transaction, Category? category)` method to `TransactionCubit` to populate the state (amount, description, date, category, type, and transaction uuid).
- **R8.** Modify the save/submit logic in `TransactionCubit`: execute `UpdateTransactionUseCase` if `existingTransactionId != null`; otherwise, execute `CreateTransactionUseCase`.

### UI & Routing
- **R9.** Update the `TransactionEntryPage` constructor to accept an optional `Transaction? existingTransaction`.
- **R10.** In `initState` of `TransactionEntryPage`, populate the form field controllers and load the transaction into the Cubit (resolving its Category from `CategoryCubit.state.allCategories`).
- **R11.** Dynamically update the AppBar title of `TransactionEntryPage` to display "Edit Transaction" instead of "New Transaction" when `existingTransaction != null`.
- **R12.** Modify the router path `/` in `app_router.dart` to retrieve the transaction from GoRouter's `extra` parameter and pass it to `TransactionEntryPage`.
- **R13.** Wrap the transaction list cards (`_TransactionCard`) in the `TransactionHistoryPage` in a `Material` and `InkWell` for premium ripple effects and visual feedback.
- **R14.** Trigger route navigation on tap using `context.push('/', extra: transaction)`.

---

## Key Technical Decisions
- **Usecase Separation:** Splitting the old `SaveTransactionUseCase` into `CreateTransactionUseCase` and `UpdateTransactionUseCase` ensures compliance with Single Responsibility Principle and facilitates clean mocking in unit tests.
- **State Load Timing:** Use `WidgetsBinding.instance.addPostFrameCallback` in `TransactionEntryPage.initState` to invoke the cubit loading method. This prevents calling state changes during widget tree construction, ensuring robust build loops.
- **Ripple Effect Preservation:** Wrap the card contents inside a transparent `Material` and `InkWell` layout to preserve the rounded card border and shadow, delivering a premium feel and visual feedback.

---

## Implementation Units

### U8.1. Domain & Data Layer
**Goal:** Add update methods to repository, local data sources, and implement the new separate use cases.

- **Files:**
  - `lib/features/transaction/domain/repositories/transaction_repository.dart`
  - `lib/features/transaction/data/repositories/transaction_repository_impl.dart`
  - `lib/features/transaction/data/datasources/transaction_local_data_source.dart`
  - `lib/features/transaction/domain/usecases/create_transaction_use_case.dart`
  - `lib/features/transaction/domain/usecases/update_transaction_use_case.dart`

- **Approach:**
  - Add interfaces and implementation code for transaction updates.
  - In Isar implementation, query by `uuid` to find the existing database ID before saving to ensure database record replacement in-place.
  - Implement use cases `CreateTransactionUseCase` and `UpdateTransactionUseCase`.

- **Test Scenarios:**
  - Unit tests to verify that `CreateTransactionUseCase` calls repository `saveTransaction`.
  - Unit tests to verify that `UpdateTransactionUseCase` calls repository `updateTransaction`.

---

### U8.2. State Management
**Goal:** Expand `TransactionState` to hold the existing transaction ID and implement form loading and submit routing in `TransactionCubit`.

- **Files:**
  - `lib/features/transaction/presentation/blocs/transaction_state.dart`
  - `lib/features/transaction/presentation/blocs/transaction_cubit.dart`

- **Approach:**
  - Add `existingTransactionId` to state.
  - Add `loadExistingTransaction` method to populate state with all attributes of the loaded transaction.
  - Update `submitTransaction` to route to either update or create.

- **Test Scenarios:**
  - Unit test `TransactionCubit` to verify that `loadExistingTransaction` populates all fields.
  - Unit test `TransactionCubit` to verify that saving calls `mockCreateTransactionUseCase` when the loaded ID is null.
  - Unit test `TransactionCubit` to verify that saving calls `mockUpdateTransactionUseCase` when the loaded ID is set.

---

### U8.3. UI & Routing Integration
**Goal:** Make history cards clickable, update routing to pass extra payload, and populate form fields on load.

- **Files:**
  - `lib/features/transaction/presentation/pages/transaction_history_page.dart`
  - `lib/features/transaction/presentation/pages/transaction_entry_page.dart`
  - `lib/app/router/app_router.dart`

- **Approach:**
  - Accept `existingTransaction` in `TransactionEntryPage` constructor.
  - Retrieve category matching the transaction from `CategoryCubit` and dispatch load events.
  - Setup InkWell inside history list item with route push logic.

- **Test Scenarios:**
  - Build and verify the app compilation.
  - Ensure all automated unit tests pass.

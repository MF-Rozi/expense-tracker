---
title: "feat: Implement Transaction History"
type: feat
status: active
date: 2026-07-03
---

# feat: Implement Transaction History

## Summary
Architectural blueprint for the Transaction History feature on the `feat/expense-transaction-history` branch. This covers extending the domain and data layers to support dynamic filtering, implementing a reactive history Cubit, and building a premium date-grouped ledger list page that mirrors the "Financial Atelier" editorial aesthetic.

---

## Problem Frame
Users need a chronological, categorized ledger view of all financial transactions ("Sovereign Ledger") with flexible search and filtering capabilities. The presentation layer must support searching by merchant/note, filtering by transaction type (income, expense, investment), filtering by category, and filtering by date range, all while rendering in a beautiful date-grouped layout.

---

## Requirements

### Domain & Data Constraints
- R1. Create the `TransactionFlowType` enum (`all`, `expense`, `income`, `investment`).
- R2. Introduce `GetTransactionsUseCase` which accepts optional filter parameters: `startDate`, `endDate`, `searchQuery` (merchant/note), `categoryId`, and `flowType`.
- R3. Implement dynamic Isar filtering in `TransactionLocalDataSource` and `TransactionRepository`.
- R4. Match description and note fields case-insensitively when `searchQuery` is provided.
- R5. Sort transactions in descending chronological order (`sortByDateDesc`) and resolve as a `Future<List<Transaction>>`.

### State Management
- R6. Create `TransactionHistoryState` holding `groupedTransactions` (as `Map<String, List<Transaction>>`), `activeFlow`, `searchQuery`, `activeCategoryId`, and `isLoading`.
- R7. Form group headers dynamically: "Today", "Yesterday", and formatted date strings (e.g., "May 14, 2024") for other dates.
- R8. Implement Cubit methods for updating search query, switching flow type, and applying custom bottom-sheet filter options (category/date range).

### Presentation & UI
- R9. Implement `TransactionHistoryPage` featuring a clean, responsive layout matching the `stitch-export.html` template.
- R10. Build the Ledger Header Section: Title "Ledger History" and subtitle "Chronological view of your sovereign capital".
- R11. Build a search input field with full pill styling (rounded-full) and a leading search icon, triggering cubit updates on change.
- R12. Render a horizontal list of Flow Chips ("All Flows", "Expenses", "Income", "Investment") with appropriate active states, plus a trailing "tune" icon button.
- R13. Implement a filter bottom-sheet triggered by the "tune" button, letting users select a specific Category (from a dropdown/chip list) and a Custom Date range (using DateRangePicker).
- R14. Display transactions grouped by date, rendering each group header with a text label and a thin horizontal divider.
- R15. Render transaction list item cards: rounded corners, circular leading icon, merchant name, category label with time, and right-aligned amount (debits/expenses in error red `-$1,299.00`, credits/income in secondary green `+$8,420.00`).
- R16. Register the page under route `/transactions` in the GoRouter configuration.

---

## Key Technical Decisions
- **Get vs Watch Paradigm:** We will create a Future-based `GetTransactionsUseCase` rather than a live stream for filter queries. This isolates filter logic from other background sync events and simplifies custom date-range queries.
- **Unified Search Criteria:** The `searchQuery` will search against both the `description` and `note` fields in the Isar database, ensuring complete search coverage.
- **Tailwind Design Mirroring:** Use `CustomScrollView` and sliver-based lists to render grouped items smoothly, maintaining structural compatibility with scroll behaviors.
- **No Automatic Commits:** All changes will remain unstaged so the user can inspect, test, and commit them.

---

## Implementation Units

### U7.1. Domain Layer Additions
**Goal:** Create flow type enum, parameter object, repository definition, and use case.

- **Files:**
  - `lib/features/transaction/domain/entities/transaction_flow_type.dart`
  - `lib/features/transaction/domain/usecases/get_transactions_use_case.dart`
  - `lib/features/transaction/domain/repositories/transaction_repository.dart`

- **Approach:**
  - Define `TransactionFlowType` containing `all`, `expense`, `income`, `investment`.
  - Add `Future<Either<Failure, List<Transaction>>> getTransactions(...)` to `TransactionRepository`.
  - Create `GetTransactionsParams` extending `Equatable`.
  - Create `GetTransactionsUseCase` extending `UseCase<List<Transaction>, GetTransactionsParams>`.

- **Test Scenarios:**
  - Unit test `GetTransactionsUseCase` to ensure parameters are passed to the repository correctly.
  - Verify `GetTransactionsParams` equality.

---

### U7.2. Data Layer Filtering
**Goal:** Implement dynamic Isar query chaining based on filters.

- **Files:**
  - `lib/features/transaction/data/datasources/transaction_local_data_source.dart`
  - `lib/features/transaction/data/repositories/transaction_repository_impl.dart`

- **Approach:**
  - Add `getTransactions(...)` to `TransactionLocalDataSource` interface and `IsarTransactionLocalDataSource` implementation.
  - Use Isar's `QueryBuilder` to dynamically chain:
    - `.dateBetween(startDate, endDate)` (if dates are specified).
    - `.group((q) => q.descriptionContains(query, caseSensitive: false).or().noteContains(query, caseSensitive: false))` (if searchQuery is present).
    - `.categoryUuidEqualTo(categoryId)` (if categoryId is present).
    - Map `TransactionFlowType` values to `TransactionType` and filter accordingly (if not `all`).
    - Terminate query with `.sortByDateDesc().findAll()`.
  - Implement the repository method to map models back to entities.

- **Test Scenarios:**
  - Unit test `IsarTransactionLocalDataSource` by populating dummy records with different dates, description names, types, and categories, then verifying each filter combination returns the expected records.

---

### U7.3. Cubit & State management
**Goal:** Create state and cubit managing filter values and date-group mapping.

- **Files:**
  - `lib/features/transaction/presentation/blocs/transaction_history_state.dart`
  - `lib/features/transaction/presentation/blocs/transaction_history_cubit.dart`

- **Approach:**
  - Define `TransactionHistoryState` with fields: `groupedTransactions` (`Map<String, List<Transaction>>`), `activeFlow`, `searchQuery`, `activeCategoryId`, `startDate`, `endDate`, `isLoading`, and `error`.
  - Define helper to convert `DateTime` to group keys: "Today", "Yesterday", and formatted date strings.
  - Implement `fetchTransactions()`: calls use case, maps output to groups, updates state.
  - Implement update handlers: `updateSearch(String)`, `updateFlowType(TransactionFlowType)`, `applyFilters(DateTime? start, DateTime? end, String? categoryId)`.

- **Test Scenarios:**
  - Use `bloc_test` to test initial state, state updates, loading indicators, and correctness of date grouping.

---

### U7.4. User Interface Implementation
**Goal:** Build Ledger History View following Tailwind aesthetic guidelines.

- **Files:**
  - `lib/features/transaction/presentation/pages/transaction_history_page.dart`
  - `lib/features/transaction/presentation/widgets/transaction_history_filter_sheet.dart`

- **Approach:**
  - Create the page wrapped in `BlocProvider` retrieving categories from `CategoryCubit` and transactions from `TransactionHistoryCubit`.
  - Build Header with custom typography.
  - Build pill-shaped Search input with debounced Cubit trigger.
  - Build flow chip row.
  - Create bottom sheet selector containing:
    - Dropdown or choice list of Categories.
    - Start date / End date text display triggering `showDateRangePicker`.
    - Apply button updating filter state.
  - Build grouped transactions using `CustomScrollView` and sliver lists. Use correct theme colors for amounts.

- **Test Scenarios:**
  - Widget tests to verify header texts exist, typing in search triggers cubit, and items are displayed.

---

### U7.5. Routing & Dependency Injection
**Goal:** Connect page route and run code generation.

- **Files:**
  - `lib/app/router/app_router.dart`
  - `lib/injector.dart`

- **Approach:**
  - Add path `/transactions` pointing to `TransactionHistoryPage` inside `lib/app/router/app_router.dart`.
  - Run `make build` to generate Injectable code.
  - Run `make test` to ensure all tests pass.

- **Test Scenarios:**
  - Verify app router resolves `/transactions` properly.

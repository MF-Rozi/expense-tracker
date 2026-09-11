---
title: "feat: Add Internal Note and Action Buttons to Transaction Entry"
type: feat
status: active
date: 2026-07-10
---

# feat: Add Internal Note and Action Buttons to Transaction Entry

## Summary
Architectural blueprint for implementing the "Internal Note" field and bottom action buttons (Save/Discard) on the `TransactionEntryPage`. This handles adding the note state management, capturing user input via a multi-line text input field, and rendering premium, accessible bottom action controls.

---

## Problem Frame
Users need a way to add private notes to their transactions for better record-keeping. In addition, having explicit "Save Transaction" and "Discard Draft" buttons at the bottom of the page (in addition to the CalculatorPad's submit hook) makes the entry workflow much more intuitive and complete.

---

## Requirements

### Domain & Data Layer
- **R1.** Ensure `note` mapping is fully functional. Since the `note` field (String?) already exists on both the `Transaction` entity and the `TransactionModel` (Isar), no database migrations or schema regenerations are required.

### State Management
- **R2.** Add `note` (as `String`) to `TransactionState`.
- **R3.** In `TransactionCubit`, add a method `updateNote(String note)` to update the state.
- **R4.** Pass `note: state.note.isNotEmpty ? state.note : null` when creating the `Transaction` object in `TransactionCubit.submitTransaction()`.
- **R5.** Populate `note` with `transaction.note ?? ''` in `TransactionCubit.loadExistingTransaction(Transaction transaction, Category? category)`.

### UI & Presentation
- **R6.** Add a new `_BentoInputCell` for "INTERNAL NOTE" below the Date selector on `TransactionEntryPage`.
- **R7.** Inside the Internal Note cell, render a `TextFormField` with `maxLines: 3`, `hintText: 'Add a private note about this transaction...'`, and bind its `onChanged` and `onTap` callbacks to update the Cubit and hide the calculator.
- **R8.** At the bottom of the scrollable form (inside the `SingleChildScrollView` of `TransactionEntryPage`), add a spacing divider and a `Column` container with two buttons:
  - **Save Transaction**: A full-width `ElevatedButton` with a dark blue background (`Color(0xFF00113A)`), white text, a leading checkmark icon (`Icons.check`), and rounded corners (`borderRadius: 24`). It triggers `TransactionCubit.submitTransaction()`.
  - **Discard Draft**: A full-width text button or light button (`TextButton`) with grey text, triggering a `Navigator.of(context).pop()` (or GoRouter `context.pop()`) to return to the previous screen.
- **R9.** Provide adequate padding below the bottom buttons to ensure they clear any system navigation bars on mobile devices.

---

## Key Technical Decisions
- **Reuse Existing Note Fields:** We will leverage the pre-existing `note` property in the `Transaction` entity and Isar `TransactionModel` instead of introducing a redundant `internalNote` field, ensuring clean domain modeling and avoiding unnecessary Isar database rebuilds.
- **Form Keyboard Dismissal:** Like other cells, tapping the Internal Note text field will call `setState(() => _isCalculatorVisible = false)` to prevent keyboard overlaps and display the native device keyboard.

---

## Implementation Units

### U9.1. State Management Additions
**Goal:** Add `note` to `TransactionState` and implement the `updateNote` event handler in `TransactionCubit`.

- **Files:**
  - `lib/features/transaction/presentation/blocs/transaction_state.dart`
  - `lib/features/transaction/presentation/blocs/transaction_cubit.dart`

- **Approach:**
  - Declare `final String note;` in `TransactionState` with a default of `''`.
  - Implement `updateNote(String note)` in `TransactionCubit`.
  - Update `loadExistingTransaction` and `submitTransaction` to incorporate the note field.

- **Test Scenarios:**
  - Unit test `TransactionCubit` to verify `updateNote` changes the state correctly.
  - Unit test `TransactionCubit` to verify that `submitTransaction` propagates the note to the use case.
  - Unit test `TransactionCubit` to verify that `loadExistingTransaction` correctly populates the note.

---

### U9.2. UI Elements & Form Integration
**Goal:** Integrate the Note input field and bottom action buttons into the page layout.

- **Files:**
  - `lib/features/transaction/presentation/pages/transaction_entry_page.dart`

- **Approach:**
  - Add the Note TextFormField cell below the Date picker.
  - In `initState`, initialize a `_noteController` using the existing note value from the widget (if editing).
  - Append the buttons column to the scrollable view and apply bottom spacing (e.g. `EdgeInsets.only(bottom: 40)`).
  - Bind "Save Transaction" to cubit submit and "Discard Draft" to pop route navigation.

- **Test Scenarios:**
  - Build the application and run unit tests (`make test`).
  - Verify that the layout remains clean and fully scrollable when the native keyboard is open.

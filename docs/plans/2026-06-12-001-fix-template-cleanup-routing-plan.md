# Plan: Template Cleanup, Package Migration, and Routing Fix

This plan outlines the steps to refactor the project from a template into the "Expense Tracker" application. It covers renaming application labels, migrating the Android package ID, and resolving a runtime `ProviderNotFoundError` by correctly scoping the `CategoryCubit` in the application router.

- **Status:** Active
- **Date:** 2026-06-12
- **Origin:** User Directive
- **Target Repo:** `expense-tracker`
- **Target Device:** Wireless ADB (`2311DRK48G`)

## 1. Problem Frame

The project currently uses template-default metadata and package identifiers (`dev.adryanev.template`). Additionally, the `CategoryManagePage` fails at runtime because its required `CategoryCubit` is not provided in the routing context.

### 1.1 Goals
- Rename the application to "Expense Tracker" across all environment flavors.
- Migrate the Android package ID to `dev.mfrozi.expense_tracker`.
- Ensure `CategoryCubit` is correctly provided to the `CategoryManagePage` route.

### 1.2 Constraints
- Maintain existing flavor dimensions (development, staging, production).
- Ensure the native Kotlin directory structure matches the new package ID.
- Use the existing dependency injection setup (`getIt`) for provider scoping.

## 2. Key Technical Decisions

### 2.1 Renaming Strategy
The application name is currently managed via `manifestPlaceholders` in `android/app/build.gradle`. We will update these placeholders and ensure the `AndroidManifest.xml` continues to use `${appName}` for its `android:label`.

### 2.2 Package ID Migration
The migration involves updating both the `namespace` and `applicationId` in `build.gradle`, as well as the `package` attribute in all `AndroidManifest.xml` variants. The physical directory structure of the Kotlin source must also be moved to prevent build failures.

### 2.3 Router Provider Scoping
The `CategoryManagePage` will be wrapped in a `BlocProvider<CategoryCubit>` within the `GoRoute` builder in `app_router.dart`. This ensures that the Cubit is available in the widget tree when the page is navigated to.

## 3. Implementation Units

### U1. Application Rename & Flavor String Refactoring
**Goal:** Update app launcher titles for all flavors.
**Files:**
- `android/app/build.gradle`
**Approach:**
- Update `productFlavors` in `android/app/build.gradle`.
- `production`: `manifestPlaceholders = [appName: "Expense Tracker"]`
- `staging`: `manifestPlaceholders = [appName: "[STG] Expense Tracker"]`
- `development`: `manifestPlaceholders = [appName: "[DEV] Expense Tracker"]`
**Test scenarios:**
- Verify `build.gradle` changes reflect the new names.
- Build the development flavor and verify the launcher title on the device.

### U2. Application Package ID Migration
**Goal:** Change package ID from `dev.adryanev.template` to `dev.mfrozi.expense_tracker`.
**Files:**
- `android/app/build.gradle`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/debug/AndroidManifest.xml`
- `android/app/src/profile/AndroidManifest.xml`
- `android/app/src/main/kotlin/dev/mfrozi/expense_tracker/MainActivity.kt` (Moved from `dev/adryanev/template/`)
**Approach:**
- Update `namespace` and `defaultConfig.applicationId` in `android/app/build.gradle`.
- Update `package` attribute in all 3 `AndroidManifest.xml` files.
- Move `MainActivity.kt` to the new directory structure: `android/app/src/main/kotlin/dev/mfrozi/expense_tracker/`.
- Update the `package` declaration in `MainActivity.kt` to `package dev.mfrozi.expense_tracker`.
**Test scenarios:**
- Verify directory structure matches the new package ID.
- Verify `AndroidManifest.xml` files are updated.
- Verify `MainActivity.kt` has the correct package header.

### U3. Router Dependency Injection Scoping Fix
**Goal:** Fix `ProviderNotFoundError` for `CategoryCubit`.
**Files:**
- `lib/app/router/app_router.dart`
**Approach:**
- Import `flutter_bloc` and `category_cubit.dart`.
- In `GoRouter` configuration, update the builder for `CategoryManagePage` to wrap it in `BlocProvider<CategoryCubit>`.
- Use `getIt<CategoryCubit>()` to provide the cubit instance.
**Test scenarios:**
- Verify the project compiles.
- Launch the app and navigate to the home route (`/`).
- Ensure the "Red Screen of Death" (ProviderNotFoundError) no longer appears.

## 4. Verification

### 4.1 Build Validation
- Run `flutter build apk --flavor development` to ensure native changes are correct.
- Verify the generated APK's package name using `aapt dump badging` or by installing on a device.

### 4.2 Runtime Validation
- Target device: `2311DRK48G` (Wireless ADB).
- Launch the app in development flavor.
- Confirm the app name is `[DEV] Expense Tracker`.
- Confirm the main screen (Category Management) loads without provider errors.

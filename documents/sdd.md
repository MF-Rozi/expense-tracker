# Software Design Document (SDD) - Expense Tracker

## 1. System Overview & Philosophy

- **Development Methodology:** Software Design Document Driven Development (SDD) & Compound Engineering.
- **Architecture Strategy:** Strict Clean Architecture (Separation of Domain, Data, and Presentation layers) utilizing the foundational template from `adryanev/flutter-mobile-clean-architecture-template`.
- **Data Strategy:** Offline-First with local reactive caching via Isar Database, synced asynchronously with Firebase Firestore. All UI elements must react directly to local database streams for instant UI updates.

---

## 2. Technical Constraints & Stack

- **Language/Framework:** Dart & Flutter
- **State Management:** `flutter_bloc` (Bloc/Cubit)
- **Local Storage:** Isar Database (using unique UUID strings for keys to facilitate cloud synchronization)
- **Remote Storage:** Firebase Firestore
- **Authentication:** Google Sign-In

---

## 3. Feature Scope

### Feature Module: Expense Categories (`feat-expense-category`)

- **Objective:** Manage a hierarchical, parent-child classification system for transactions.
- **Structural Rules:**
  - Parent categories have a unique `uuid` and no `parentUuid`.
  - Child subcategories must reference a parent's valid `uuid` via a `parentUuid` property.
  - Deleting a parent category should cascade or safely handle orphan subcategories (Business logic to be detailed in Data Layer).
  - Data fields must track synchronization status (`isSynced` and `updatedAt`) for the Sync Engine.

### Feature Module: Core Expenses (Pending)

- **Objective:** Track financial transactions mapped to specific categories.
- **Data Fields:**
  - `uuid`: String (Primary Index for sync matching)
  - `amount`: Double
  - `date`: DateTime
  - `categoryUuid`: String (Foreign key pointing to CategoryCollection.uuid)
  - `notes`: String (Optional)
  - `isSynced`: Boolean
  - `updatedAt`: DateTime
- **Gamification:** Include a daily logging streak tracker system to incentivize user retention.

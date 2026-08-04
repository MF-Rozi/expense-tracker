# Feature Specification: Financial Architecture (Category Overhaul)

## 1. Domain & Terminology Shift

- **Categories** are now referred to as **Envelopes**.
- **Income/Expense** groupings are referred to as **Pillars**.
- The system requires a strict hierarchical structure: `Primary Pillar > Sub-Parent > Child Envelope`.

## 2. Core Data Additions

- **Expected Monthly Budget/Amount:** Each envelope needs a numeric baseline for forecasting.
- **Behavioral Modifiers:** Envelopes must support tagging as `Active`, `Passive`, or `Recurring`.

## 3. UI Component Requirements

### 3.1 New Category Form (TransactionEntryPage counterpart)

- **Top Toggle:** Segmented control for Expense vs. Income.
- **Breadcrumb Header:** A visual row displaying the current nesting (e.g., `Primary Pillar > Sub-Parent > Child Envelope`).
- **Envelope Type Selector:** Large square cards (Essential, Lifestyle, Growth) with icons. Active state uses the deep primary blue (`Color(0xFF00113A)`); inactive uses a light grey.
- **Budget Input:** Centered, large typography for logging the expected monthly baseline.
- **Modifier Toggles:** Three horizontal pill-shaped buttons for Active, Passive, and Recurring.
- **Hierarchy Insight Card:** A dynamic bottom container displaying a summary string (e.g., "'Artisanal Coffee' will be nested under Lifestyle > Dining.")

### 3.2 Envelope Dashboard

- **Portfolio Distribution Card:** A premium dark-blue header card showing the total allocated budget, with a horizontal multi-color progress bar breaking down the percentage distribution.
- **Nested List View:** Categories must be displayed in expandable/collapsible tree structures (e.g., 'Essential' parent -> 'Mortgage & Rent', 'Utilities' children) with budget allocations listed on the trailing edge.

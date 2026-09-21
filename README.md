# LEDGER

A neo-brutalist expense tracker built with Flutter. Log expenses, categorize them, see where the
money went this month, and lock sensitive actions behind a PIN. All data lives locally on the
device — no accounts, no network.

## Screenshots

| Home | Stats |
| --- | --- |
| ![Home screen showing this month's total and a list of expenses](docs/screenshots/home.png) | ![Stats screen showing spending by category](docs/screenshots/stats.png) |

| New expense | Options |
| --- | --- |
| ![New expense form with amount, description, and category picker](docs/screenshots/add_expense.png) | ![Options sheet with quick actions and settings](docs/screenshots/options.png) |

<details>
<summary>Drawer and onboarding</summary>

| Drawer | Onboarding |
| --- | --- |
| ![Navigation drawer showing the user's name and monthly budget](docs/screenshots/drawer.png) | ![First onboarding page: "Track your money"](docs/screenshots/onboarding.png) |

</details>

## Features

- **Expense tracking** — add, edit, and delete expenses with an amount, description, category, date,
  and optional note.
- **Time filters** — view totals for today, the last 7 days, the current month, or all time.
- **Stats** — this month's spending broken down by category, with bar chart and percentage breakdown.
- **Monthly budget** — set a budget during onboarding, edit it later from the options sheet.
- **PIN lock** — an optional PIN gates editing, deleting, changing your name or budget, and clearing
  all data.
- **Onboarding** — a four-step first-run flow (welcome, name, budget, categories) that can be
  restarted from the options sheet.

## Getting started

Requires the Flutter SDK (Dart SDK `^3.13.3`).

```bash
flutter pub get
flutter run            # add -d <device_id> to pick a target
```

`flutter devices` lists connected emulators, simulators, and browsers.

The Dart package is `ledger`; the application id / bundle id is `com.example.ledger`.

## Architecture

State is managed with **BLoC** (`flutter_bloc`). Two blocs are provided above `MaterialApp` in
`lib/app.dart`, so every route and dialog can reach them:

### `ExpenseBloc`

Owns every expense and the active time filter.

| Event | Effect |
| --- | --- |
| `LoadExpenses` | Reads the full list from SQLite. |
| `FilterChanged` | Switches the active `TimeFilter`. |
| `ExpenseAdded` / `ExpenseUpdated` / `ExpenseDeleted` | Writes through to SQLite, then re-reads. |
| `AllExpensesCleared` | Deletes every row, then re-reads. |

`ExpenseState` holds the *complete* list (`all`) plus the active filter. The views it feeds are
derived getters — `filtered` and `total` respect the user's filter, while `thisMonth` and
`monthlyCategoryTotals` always use the calendar month. That lets Home and Stats read different
slices of one source of truth, and it means every write re-emits state for both screens at once.

### `SettingsBloc`

Owns the three `SharedPreferences` keys — `user_name`, `monthly_budget`, and
`onboarding_complete` — via `UserNameChanged`, `BudgetChanged`, `OnboardingCompleted`, and
`OnboardingReset`. No widget reads `SharedPreferences` for these values directly, so a change in the
options sheet updates the drawer and the home header immediately.

`AuthCheck` in `lib/app.dart` watches `SettingsState.onboardingComplete` and swaps between
`OnboardingScreen` and `MainShell` — completing or resetting onboarding is a state change, not a
navigation stack rewrite.

### Persistence

- **SQLite** (`sqflite`) for expenses — schema and queries live in
  `lib/database/database_helper.dart`, a singleton the blocs call directly.
- **SharedPreferences** for settings and the PIN.

## Project layout

```
lib/
├── main.dart                 # entry point only; re-exports app/theme for convenience
├── app.dart                  # MultiBlocProvider, MaterialApp, AuthCheck
├── theme.dart                # neo-brutalist colors, shadows, ThemeData
├── bloc/
│   ├── expense/              # event / state / bloc
│   └── settings/             # event / state / bloc
├── models/expense.dart       # Expense model + the category list
├── database/
│   └── database_helper.dart  # sqflite schema and queries
├── screens/
│   ├── main_shell.dart       # scaffold: drawer, tabs, FAB, bottom nav
│   ├── home_screen.dart      # expense list, totals, time filters
│   ├── stats_screen.dart     # category breakdown
│   ├── add_expense_screen.dart
│   └── onboarding/           # welcome, name, budget, categories, tutorial
└── widgets/                  # drawer, options sheet, PIN dialog, cards, animations
```

## Testing

```bash
flutter test                                  # unit + widget tests
flutter test integration_test                 # needs a connected device
flutter analyze
```

`test/expense_state_test.dart` covers the filtering and totals logic in `ExpenseState` — the part
most likely to break silently, since it decides what every screen displays.

## Notes

- The app is offline-only. Nothing is uploaded, and there is no backup — clearing app data or
  using **CLEAR ALL DATA** is irreversible.
- The PIN is a convenience lock stored in plain `SharedPreferences`. It keeps casual hands out of
  your expenses; it is not encryption and does not protect the SQLite file itself.

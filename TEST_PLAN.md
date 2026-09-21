# Edge Cases & Business Flow Test Plan

## 1. ONBOARDING FLOW
- [ ] App launches → shows onboarding (fresh install)
- [ ] Welcome page → tap CONTINUE → navigates to name page
- [ ] Name page → leave empty → CONTINUE button does nothing
- [ ] Name page → type name → greeting preview updates live ("HEY, JOHN!")
- [ ] Name page → tap CONTINUE → navigates to budget page
- [ ] Budget page → tap preset chip ($500) → value updates in field
- [ ] Budget page → type custom amount → saves to SharedPreferences
- [ ] Budget page → tap CONTINUE → navigates to done page
- [ ] Done page → tap START → saves `onboarding_complete: true`, navigates to home
- [ ] Onboarding complete → restart app → skips onboarding, goes to home

## 2. HOME SCREEN
- [ ] Empty state shows "NOTHING YET." with pulsing box icon
- [ ] "ADD FIRST EXPENSE" CTA button visible in empty state
- [ ] CTA button → opens AddExpenseScreen
- [ ] FAB (+) → opens AddExpenseScreen
- [ ] Header shows correct greeting (user name or "HEY THERE")
- [ ] Header shows today's date
- [ ] Summary card shows total for selected filter
- [ ] Time filter: TODAY → shows today's expenses only
- [ ] Time filter: WEEK → shows last 7 days
- [ ] Time filter: MONTH → shows current month
- [ ] Time filter: ALL → shows all expenses
- [ ] Expense list groups by date (TODAY/YESTERDAY/DATE)
- [ ] Day header shows day total
- [ ] Expense cards show icon, title, amount, date
- [ ] Staggered list entry animations work

## 3. ADD EXPENSE
- [ ] Amount field autofocus on new expense
- [ ] Amount field accepts decimals (e.g. "12.50")
- [ ] Amount field rejects non-numeric input
- [ ] Amount = 0 → shows "MUST BE > 0" error
- [ ] Amount empty → shows "ENTER AMOUNT" error
- [ ] Error text visible (pink, bold, below field)
- [ ] Description field empty → shows "REQUIRED" error
- [ ] Category chips: tap to select, visual feedback (black bg + yellow text)
- [ ] Food is pre-selected by default
- [ ] Date picker opens on tap, defaults to today
- [ ] Date cannot be future (lastDate = DateTime.now())
- [ ] Note field is optional, can be left empty
- [ ] SAVE button → validates → if invalid, shows errors
- [ ] SAVE button → valid → saves to SQLite → shows SnackBar "EXPENSE ADDED" → pops
- [ ] Close (X) button → pops without saving
- [ ] Add new expense → home list refreshes, total updates

## 4. EDIT EXPENSE
- [ ] Tap expense card → PIN dialog appears (if PIN set)
- [ ] Correct PIN → navigates to AddExpenseScreen in edit mode
- [ ] Wrong PIN → shows "WRONG PIN" error, fields clear
- [ ] No PIN set → directly opens edit screen
- [ ] Title shows "EDIT" instead of "NEW EXPENSE"
- [ ] All fields pre-populated with expense data
- [ ] DELETE button visible at bottom
- [ ] SAVE → PIN check → updates expense → SnackBar "EXPENSE UPDATED" → pops
- [ ] Home list refreshes, total updates after edit

## 5. DELETE EXPENSE
- [ ] Swipe left on expense card → red DELETE background
- [ ] Release → PIN dialog (if PIN set)
- [ ] Confirm dialog → DELETE → expense removed
- [ ] Long press on card → same flow
- [ ] Delete button in edit mode → PIN → confirm → delete → pops
- [ ] After delete: home list refreshes, total updates

## 6. STATS SCREEN
- [ ] Tap STATS tab → switches to stats view
- [ ] Empty state → shows "NO DATA YET."
- [ ] With data → bar chart shows by category
- [ ] Bars animate from 0 to correct width (no overflow)
- [ ] Category breakdown shows icon, name, percentage, amount
- [ ] Total percentage adds up to ~100%
- [ ] Switch back to HOME → add expense → switch to STATS → data refreshes

## 7. BOTTOM SHEET (OPTIONS)
- [ ] Tap settings icon → DraggableScrollableSheet opens
- [ ] EDIT BUDGET → PIN check → dialog → saves new budget
- [ ] CHANGE NAME → PIN check → dialog → saves new name
- [ ] ABOUT APP → shows version info
- [ ] SET / CHANGE PIN → opens SetPinDialog
- [ ] RESTART ONBOARDING → confirm → resets to onboarding
- [ ] CLEAR ALL DATA → PIN check → confirm → deletes all expenses
- [ ] Drag handle visible at top

## 8. PIN SYSTEM
- [ ] No PIN set → all operations allowed without prompt
- [ ] SET PIN → enter 4+ digits → confirm → saved to SharedPreferences
- [ ] PIN < 4 digits → shows "MIN 4 DIGITS" error
- [ ] PIN mismatch → shows "PINS DON'T MATCH" error
- [ ] PIN set → edit/delete/clear operations prompt for PIN
- [ ] Wrong PIN → "WRONG PIN" error, fields clear
- [ ] Correct PIN → operation proceeds
- [ ] CHANGE PIN → enter new PIN → saves
- [ ] REMOVE PIN → deletes stored PIN → operations no longer prompt
- [ ] PIN persists across app restarts

## 9. DRAWER
- [ ] Tap hamburger menu → drawer opens
- [ ] HOME → closes drawer, shows home tab
- [ ] STATS → closes drawer, shows stats tab
- [ ] BUDGET → closes drawer, opens bottom sheet
- [ ] User profile shows name
- [ ] Budget card shows current budget

## 10. PERSISTENCE
- [ ] Add expense → kill app → reopen → expense still there (SQLite)
- [ ] Change filter → kill app → reopen → filter resets to MONTH (default)
- [ ] Change name → persists across restarts
- [ ] Change budget → persists across restarts
- [ ] Onboarding complete → persists across restarts
- [ ] PIN code → persists across restarts

## 11. EDGE CASES
- [ ] Add expense with very long title (>50 chars) → truncates properly
- [ ] Add expense with amount $0.01 → works
- [ ] Add expense with amount $99999.99 → works
- [ ] Add expense with note containing newlines → works
- [ ] Swipe delete while list is empty → no crash
- [ ] Rapid FAB tapping → no duplicate screens
- [ ] Back button on AddExpenseScreen → pops correctly
- [ ] Multiple rapid saves → no duplicate entries
- [ ] Edit expense while another edit is in progress → no crash
- [ ] Clear all data → home shows empty state again
- [ ] Restart onboarding after adding expenses → expenses persist, onboarding resets

# Grouped Navigation List Spec

Status: Active supporting design canon.

## Naming Stack

- Pattern: Grouped Navigation List.
- Visual descriptor: Settings-style grouped list.
- Section: Navigation Section.
- Primary row: Navigation Row.
- Chevron row: Disclosure Navigation Row.
- Toggle row: Preference Row.
- Status/value row: Status Navigation Row.
- Destructive row: Destructive Action Row.
- Code component: `GroupedNavigationList`.

## Usage Rules

- Use Grouped Navigation Lists for categorized secondary navigation, settings, trust controls, archives, and object depth.
- Do not use them as the primary execution UI.
- Do not replace Hero Decision Panels, Today Plan Panels, Goal cards, Capture input, or Plan timeline controls with grouped lists.
- Rows must have stable targets, clear labels, VoiceOver values/hints when stateful, and visible alternatives for destructive or sensitive actions.

## Examples

### You

Use heavily for Profile, Personalization, What Ambitions Knows, Reviews, Analytics, Trust & Explanations, Privacy, Sync / Export, Integrations, Appearance, Notifications, Accessibility, and Settings.

### Goal Detail

Use selectively for subpages, settings, history, archive, proof detail, decision history, and deeper configuration. The main Mission Control lanes remain the primary UI.

### Plan Controls

Use for calendar-aware mode, ritual preferences, review archive, open-window settings, and scheduling preferences. The believability hero and timeline remain primary.

### Capture Routing

Use for route categories, Needs a Place archive-like depth, and capture settings. Fast input and suggested routes remain primary.

### Trust Center

Use for explanation, correction, receipts, privacy, sync/export, safe automation, and platform surface status.

### Memory

Use for memory categories, freshness states, correction routes, delete controls, and recoverable history where technically safe.

### Settings

Use for stable product preferences. Destructive Action Rows require confirmation and clear consequence copy.

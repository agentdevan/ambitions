# Ambitions You, Profile, Settings, And Reviews

Status: Active canon consolidation layer.

Purpose: Consolidate You, Profile migration, settings, trust, memory, reviews, personalization, Appearance Studio, and data controls into one implementation-readable reference. This document reflects Wave 9 product decisions.

## Core You Doctrine

You is the user's personal system center.

Core job:

```text
Personal system center
```

You should contain:

```text
Settings
Trust
Memory
Reviews
Personalization
```

You is not:

- a generic settings page
- a junk drawer
- an analytics dashboard
- a social profile
- primary execution UI

## You Top Status

Main top status:

```text
You are in control
```

Rules:

- The top status should reinforce user control, not system authority.
- Avoid numerical trust scores at launch.
- Supporting rows can summarize memory, receipts, privacy, calendar access, sync/export truth, Appearance Studio, and review status.

## Surface Contents

Recommended You sections:

### Personalization

- Appearance Studio
- Display density
- Panel size
- Accent / theme
- Focus support preferences
- Life Area naming/preferences

### Trust

- Trust Center
- Receipts
- Decision Trail
- What Changed
- Safe Automation Boundary

### Memory

- What Ambitions Knows
- Memory Review
- Pause Memory Learning
- Delete All Memory
- Corrections

### Reviews

- Daily Receipt
- Weekly Life OS Receipt
- Goal Reviews
- Memory Reviews
- Pattern Reviews
- Recovery Reviews

### Data / Platform

- Export / Import when implemented
- Sync / backup status when implemented
- Calendar access
- Notifications privacy
- Widgets / Live Activities / App Intents status where relevant

### Settings

- App preferences
- Privacy controls
- Accessibility/support controls
- About / version / legal where needed

Rules:

- You can be deep, but top-level You should remain organized and calm.
- Grouped Navigation List is the default structure for settings-style navigation.
- Avoid dumping every low-value setting into the first screen.

## Settings Pattern

Official pattern:

```text
Grouped Navigation List
```

Visual descriptor:

```text
Settings-style grouped list
```

Rules:

- Use for settings, trust controls, memory controls, Appearance Studio entry, and data controls.
- Rows should have clear labels, concise descriptions where useful, and chevrons for drilldown.
- Group sections should be named by user intent, not internal system names.

## Profile Naming Migration

Resolved naming direction:

```text
Canonical naming should move fully to You.
Profile is legacy compatibility terminology during migration only.
```

Rules:

- New user-facing copy should say `You`, not `Profile`.
- New docs should use `You` as canonical surface language.
- Future batch prompts should avoid introducing new `Profile` terminology except to reference legacy code.
- Existing code paths named `Profile` should be migrated deliberately to `You` where safe.
- Temporary compatibility shims may remain during migration only when needed to avoid breaking the app.
- Completion summaries should call out any remaining `Profile` compatibility names if they are still present.

## Reviews

Reviews primarily turn what happened into what should happen next.

Primary review purpose:

```text
Turn what happened into what should happen next.
```

Reviews should not primarily:

- judge performance
- keep streaks
- show generic history
- act as dashboard analytics
- shame the user

Review outputs should answer:

- What happened?
- What changed?
- What still holds?
- What no longer holds?
- What should happen next?
- What should be corrected?
- What should be remembered, if confirmed and appropriate?

Rules:

- Reviews can show patterns, but not as dashboard analytics.
- Reviews should convert history into next action, recovery, memory correction, or plan adjustment.
- Reviews should be calm, non-shaming, and useful even after drift.

## Analytics Boundary

You may show analytics only as:

```text
Reviews / Patterns
```

Rules:

- Do not make You a dashboard analytics surface.
- Avoid KPI wall design.
- Patterns should be explainable and action-oriented.
- Pattern insights should lead to correction, review, planning, or memory controls.

## Export / Import

Resolved direction:

```text
Export/import belongs in You when implemented, surfaced through Trust Center / Data controls.
```

Rules:

- Do not claim export/import before implemented.
- Export/import should have receipts.
- Export failure should explain what remains safe.
- Delete-all-memory should offer export/reminder first where export exists.

M02 status:

- Service-level portable export/import proof now exists through `PortableAppSnapshot` and `PortableSnapshotService`.
- Export packages name selected categories, privacy preview rules, and excluded cloud/calendar/external-rendered state.
- Import reports include safety summaries and warnings.
- A user-facing You / Trust Center export/import surface is still future-owned; do not present a finished UI unless that surface is implemented.

## Appearance Studio

Resolved direction:

```text
Appearance Studio belongs in You.
```

Rules:

- Appearance Studio owns appearance, accent, display density, panel size, and related personalization.
- Display changes should prefer receipt + undo where meaningful.
- Onboarding defaults to Balanced + Comfortable and does not ask for density up front.

## You Must Never Become

You must never become:

```text
Junk drawer.
Analytics dashboard.
Generic settings page.
Social profile.
```

## QA Acceptance Criteria

You / Reviews is acceptable when:

- You functions as a personal system center.
- You contains settings, trust, memory, reviews, and personalization.
- Top status is `You are in control`.
- Settings-style areas use Grouped Navigation List.
- New user-facing copy says `You`, not `Profile`.
- Remaining `Profile` naming is treated as migration/compatibility only.
- Reviews turn what happened into what should happen next.
- Analytics appear only as Reviews/Patterns, not dashboard analytics.
- Export/import appears only when implemented and through Trust Center / Data controls.
- Appearance Studio is available through You.
- You does not become a junk drawer, analytics dashboard, generic settings page, or social profile.

## Open Questions For Future Waves

- What should the first-screen You layout show above the grouped navigation list?
- Should Reviews have a single hub or separate Daily/Weekly/Goal/Memory routes?
- What exact Appearance Studio controls ship first?
- Should `Profile` code migration happen in one batch or progressively by feature area?
- Should You expose Life Area management directly or through Goals + Settings routes?

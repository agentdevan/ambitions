# Ambitions Implementation Backlog

This backlog translates the current roadmap into implementation work that matches the live native codebase in `Native/Ambitions/`.

## Current repo truth

- The shipping product is the native SwiftUI app.
- The live native target is local-first and on-device first.
- The app currently ships repository-backed Today, Captures, Goals, Habits, Insights, and Profile surfaces backed by SwiftData repositories for goals, drafts, plans, steps, evidence, feedback, captures, and app state.
- Notifications, widgets, Live Activities, and calendar/reminders integrations are available as native device features.
- Account sync, auth, and backend-driven account deletion are not current shipping features.

## Roadmap mismatches against the current codebase

### 1. Sync is treated as a late-phase add, but older docs still describe live Supabase auth/sync as if it exists now

Why this matters:
- The README and Profile service both describe the native app as local-only today.
- Several docs still describe active Supabase auth, sync, and account deletion flows.
- Any implementation plan that ignores this conflict will create more source-of-truth drift.

Backlog impact:
- Add a documentation cleanup phase before feature work.
- Mark Supabase/auth docs as historical unless and until a native sync decision is made.

### 2. "Quick capture" exists as presentation state, not as a persisted capture domain

Why this matters:
- The roadmap assumes share-sheet capture, App Intents capture, and a canonical capture object.
- The current code only exposes a `TodayQuickCaptureState` panel and a `quickLog` action inside Today.
- There is no capture repository, capture SwiftData model, or cross-surface ingestion layer yet.

Backlog impact:
- Add a dedicated capture-domain phase before Share Extension and App Intents work.

### 3. Widgets and Live Activities are blocked on shared export/storage work that does not exist yet

Why this matters:
- `AmbitionsWidgetUI` is an in-app package, not a WidgetKit extension target.
- The app has no app group, no shared snapshot writer, and no extension-safe read model.
- The roadmap jumps directly to WidgetKit and ActivityKit without first defining the export path.

Backlog impact:
- Insert a shared snapshot/export phase before WidgetKit and Live Activities.

### 4. Notifications are planned as product work, but there is no background capability or external routing boundary yet

Why this matters:
- The current service boundary has no notification services.
- The current app action router only handles in-app `WidgetAction` tab routing.
- There is no notification authorization model, scheduler, deep-link parser, or external action dispatcher.

Backlog impact:
- Add an external-routing and background-actions foundation phase before notifications.

### 5. Calendar/Reminders integration is planned without a permissions/privacy preparation phase

Why this matters:
- `Info.plist` currently has no notification, calendar, reminder, widget, or Live Activity related keys.
- The roadmap assumes EventKit and system integrations, but the current target has not prepared privacy text, entitlements, or extension metadata.

Backlog impact:
- Add a permissions, entitlements, and privacy-manifest phase before system integrations.

### 6. Auto-rescheduling is planned after EventKit, but the codebase lacks a dedicated reschedule engine boundary today

Why this matters:
- The app already stores feedback events and suggested timing fields, which is good groundwork.
- But there is no explicit `RescheduleEngine`, policy layer, or stable patch format for timing updates.
- Tying the first reschedule implementation directly to EventKit would over-couple two separate concerns.

Backlog impact:
- Build the deterministic reschedule engine before calendar-aware optimization.

## Missing phases

These phases are not represented clearly enough in the original roadmap and should be added.

### Phase A. Documentation and source-of-truth cleanup

Goals:
- Mark stale auth/sync docs as historical or explicitly scoped to legacy/native-future work.
- Add a docs index that distinguishes live native docs from historical migration material.
- Remove ambiguity about whether sync/auth is currently shipped.

Deliverables:
- `docs/README.md`
- status note on historical Supabase/auth docs
- cross-links from `README.md`

### Phase B. Capture domain and persistence foundation

Goals:
- Define a first-class capture object model before Share Extension or App Intents work.
- Decide whether captures can remain lightweight notes, become inbox items, or promote into goals.
- Add SwiftData models, repositories, and service boundaries for capture ingestion and review.

Deliverables:
- `CaptureRecord` SwiftData model
- `CaptureRepository`
- `CaptureServicing`
- minimal in-app capture inbox surface or Today integration

### Phase C. Shared export/snapshot layer for external surfaces

Goals:
- Create a stable, extension-safe export format for widgets, intents, live activities, and possible sync.
- Avoid making extensions read SwiftData internals directly.
- Centralize derived "next step", "focus session", and "capture summary" snapshots.

Deliverables:
- shared app-group capable snapshot writer/reader
- read-only JSON snapshot contracts
- tests for snapshot generation

### Phase D. External routing and background action foundation

Goals:
- Introduce a routing layer that can handle notification taps, widget taps, intents, and future deep links.
- Separate app navigation decisions from OS-surface event handling.
- Define a stable action-dispatch contract for background and extension flows.

Deliverables:
- deep-link parser/router
- external action dispatcher
- app open target model

### Phase E. Permissions, entitlements, and privacy preparation

Goals:
- Prepare `Info.plist`, entitlements, privacy manifest, and XcodeGen target config before shipping system integrations.
- Keep this as a deliberate phase instead of scattering permission changes across later work.

Deliverables:
- permission copy inventory
- entitlement/app-group plan
- `PrivacyInfo.xcprivacy` review for added APIs

## Proposed implementation order

### 0. Baseline and docs cleanup

- Keep native-only source-of-truth rules explicit.
- Add `docs/README.md` with live vs historical doc status.
- Remove backend-flow docs from the active native doc set unless a native sync track is approved.

### 1. Capture domain foundation

- Introduce persistent capture entities and repositories.
- Rework Today quick capture to read/write real capture data instead of only presentation state.
- Add tests for capture creation, listing, and promotion rules.

### 2. External routing foundation

- Add a deep-link and open-target model.
- Expand app action routing beyond current in-app widget tab switching.
- Add tests for route parsing and target selection.

### 3. Shared snapshots for external surfaces

- Add an app-group compatible snapshot export layer.
- Export at least:
  - next step snapshot
  - focus session snapshot
  - capture summary snapshot
- Add deterministic snapshot tests.

### 4. Permissions and privacy preparation

- Add missing permission strings and entitlements only after the feature scope is finalized.
- Update `project.yml`, `Info.plist`, and privacy metadata in one deliberate pass.

### 5. Notifications foundation

- Add notification authorization and category registration.
- Schedule one daily "next tiny step" prompt.
- Support `Complete`, `Snooze`, and `Open`.
- Route notification opens through the new routing layer.

### 6. Deterministic reschedule engine

- Implement a standalone `RescheduleEngine`.
- Feed it existing feedback events and timing fields.
- Keep this engine independent of EventKit in its first iteration.

### 7. WidgetKit extension

- Add a new extension target via `project.yml`.
- Read from shared snapshots instead of the app database.
- Ship a single "Next tiny step" widget first.

### 8. Live Activities / focus session

- Define a first-class focus session domain model.
- Add ActivityKit support only after shared snapshots and routing exist.
- Keep it local-only at first.

### 9. Calendar and Reminders integration

- Add EventKit service boundaries and permission handling.
- Start with optional write flows and conflict checks.
- Integrate with the reschedule engine only after the base reschedule logic is stable.

### 10. Share Extension and App Intents

- Build these on top of the capture domain, shared snapshots, and routing foundation.
- Start with:
  - save text/URL capture
  - open goals
  - start focus session

### 11. Sync decision and scaffolding

- Make an explicit backend decision first.
- Add sync boundaries and snapshot export/import contracts before any real provider integration.
- Keep the app fully local-only by default until a native sync path is approved.

## Suggested work items by repo area

### App and navigation

- `Native/Ambitions/App/`
  - add external route handling
  - add open-target parsing
  - keep tab and goal-detail routing centralized

### Services

- `Native/Ambitions/Services/`
  - add `CaptureServicing`
  - add notification service boundaries
  - add calendar service boundaries
  - add sync capability boundaries

### Persistence

- `Native/Ambitions/Persistence/`
  - add capture models/repositories
  - add snapshot export contracts
  - add sync export/import support

### Features

- `Native/Ambitions/Features/Today/`
  - convert quick capture from presentational-only state into repository-backed behavior
- `Native/Ambitions/Features/Profile/`
  - host connected-feature status, permissions education, and sync readiness states
- `Native/Ambitions/Features/Goals/`
  - integrate reschedule actions and optional calendar/reminder flows

### Project configuration

- `project.yml`
  - add extension targets only after foundations exist
- `Native/Ambitions/Support/Info.plist`
  - add permissions only when each surface is actually introduced

## Recommended acceptance gates

- Do not start WidgetKit, ActivityKit, Share Extension, or App Intents work until shared snapshots and routing exist.
- Do not start sync implementation until the backend decision is documented.
- Do not treat old Supabase docs as live-native product truth.
- Keep all new shipping work inside `Native/Ambitions/`, `Sources/`, `AppUI/Sources/`, or new native extension folders added through `project.yml`.

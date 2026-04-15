# Ambitions Implementation Backlog

This backlog translates the current roadmap into implementation work that matches the live native codebase in `Native/Ambitions/`.

## Current repo truth

- The shipping product is the native SwiftUI app.
- The live native target is local-first and on-device first.
- The app currently ships repository-backed Today, Captures, Goals, Habits, Insights, and Profile surfaces backed by SwiftData repositories for goals, drafts, plans, steps, evidence, feedback, captures, and app state.
- `project.yml` currently defines the `Ambitions` app target, the `AmbitionsWidgetExtension` target, and the unit/UI test bundles.
- The current native codebase already includes capture persistence, create-goal submission, external routing, snapshot export, local notification scheduling, EventKit integration, and widget/live-activity code paths.
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

### 2. Capture persistence now exists; the remaining gap is cross-surface rollout discipline

Why this matters:
- The native app already has `Capture`, `CaptureRecord`, `SwiftDataCaptureRepository`, `DefaultCaptureService`, and a `CapturesScreen`.
- Today quick capture now writes through the capture service instead of remaining presentation-only state.
- Share Extension and App Intent capture source types exist in the domain/tests, but those OS surfaces still need their own target-level wiring and end-to-end validation.

Backlog impact:
- Do not schedule another net-new capture-foundation phase.
- Treat future Share Extension and App Intents work as incremental work on top of the existing capture boundary.

### 3. Widget/Live Activity foundations exist; remaining work is validation and scope control

Why this matters:
- `project.yml` already defines `AmbitionsWidgetExtension`.
- The repo already includes shared snapshot contracts/store code and app-group entitlements for the app and widget extension.
- The codebase contains both WidgetKit and ActivityKit surfaces, so planning should start from validation of the existing path rather than from a missing-foundation assumption.

Backlog impact:
- Keep external-surface work incremental.
- Prioritize truth cleanup and environment validation before expanding widget/live-activity scope further.

### 4. Notification and external-routing foundations already exist; the remaining work is behavior hardening

Why this matters:
- `LocalNotificationFoundation` already handles category registration, authorization requests, schedule refresh, and live-activity refresh.
- `AppExternalRouting` already translates deep links, notifications, and widget payloads into app navigation targets.
- The next risk is not missing architecture; it is whether the current behavior has been fully validated on-device/simulator.

Backlog impact:
- Do not re-plan notification/routing as greenfield infrastructure work.
- Validate and refine the current routing and notification behavior on the existing seams.

### 5. EventKit and privacy preparation exist; remaining work is explicit product gating and validation

Why this matters:
- `EventKitIntegrationService` is already part of the live native container.
- `Info.plist` already contains calendar/reminder usage descriptions, and the app/extension already carry app-group entitlements.
- The current uncertainty is feature readiness, not whether permission/config scaffolding exists at all.

Backlog impact:
- Avoid redoing permissions/entitlements prep as if it is still absent.
- Treat further calendar/reminder work as iterative hardening on top of the current service/configuration layer.

### 6. A native reschedule engine exists; remaining work is policy integration and validation

Why this matters:
- The app already stores feedback events and suggested timing fields, which is good groundwork.
- The repo now also has a dedicated `Native/Ambitions/Domain/Reschedule/RescheduleEngine.swift`.
- Follow-on work should extend or validate that existing boundary rather than assuming scheduling logic is still missing.

Backlog impact:
- Keep calendar-aware work layered on top of the current reschedule boundary.

## Remaining phases

These are the phases that still matter after the native foundations already landed.

### Phase A. Documentation and source-of-truth cleanup

Goals:
- Mark stale auth/sync docs as historical or explicitly scoped to legacy/native-future work.
- Keep implementation docs aligned with the current native service, routing, capture, and extension boundaries.
- Remove ambiguity about what is implemented versus what has merely been scaffolded.

Deliverables:
- `docs/README.md`
- status note on historical Supabase/auth docs
- corrections in backlog/audit docs when architecture changes land

### Phase B. External-surface validation and hardening

Goals:
- Validate the current deep-link, notification, widget, live-activity, and EventKit paths in a real build/runtime workflow.
- Tighten copy, routing, and fallback behavior only where the current implementation proves weak.
- Keep system-surface expansion bounded to the seams that already exist.

Deliverables:
- manual validation notes
- follow-up fixes for any notification/widget/EventKit drift found during validation
- truth-checked docs describing verified behavior versus unverified foundations

### Phase C. Sync decision and historical-doc containment

Goals:
- Make an explicit native sync decision before any provider-specific implementation resumes.
- Keep older Supabase/auth/account-deletion material clearly labeled as historical until that decision changes.

Deliverables:
- documented sync decision
- historical labeling for legacy docs that still mention live auth/sync/account deletion

## Proposed implementation order

### 0. Baseline and docs cleanup

- Keep native-only source-of-truth rules explicit.
- Add `docs/README.md` with live vs historical doc status.
- Remove backend-flow docs from the active native doc set unless a native sync track is approved.

### 1. Validate the existing native foundations

- Validate create-goal, capture persistence, external routing, notification scheduling, EventKit behavior, and widget/live-activity reads against the current code.
- Fix only the gaps exposed by that validation pass.

### 2. Harden capture and external-surface behavior on the existing seams

- Extend the current capture service/repository path instead of rebuilding capture foundations.
- Keep routing work inside `AppExternalRouting`, snapshot export, and the existing service layer.

### 3. Decide sync before reviving backend work

- Make the backend/sync decision explicit before treating old auth/sync docs as live work again.
- Keep the app local-first until a native sync path is deliberately approved.

## Suggested work items by repo area

### App and navigation

- `Native/Ambitions/App/`
  - keep tab, goal-detail, and external-entry routing centralized
  - validate the current deep-link/notification/widget handoff before introducing new route seams

### Services

- `Native/Ambitions/Services/`
  - keep `CaptureServicing`, notification scheduling, and calendar/reminder boundaries as the extension points
  - add new capability boundaries only when a new product surface actually needs them

### Persistence

- `Native/Ambitions/Persistence/` and `Native/Ambitions/ExternalSnapshots/`
  - treat capture persistence and snapshot export as existing truth
  - extend them incrementally instead of recreating a second foundation

### Features

- `Native/Ambitions/Features/Today/`
  - keep quick capture on the current repository-backed path
- `Native/Ambitions/Features/Profile/`
  - host connected-feature status, permissions education, and sync readiness states only when verified product behavior exists
- `Native/Ambitions/Features/Goals/`
  - keep create-goal, reschedule, and optional calendar/reminder work on the current service layer

### Project configuration

- `project.yml`
  - extend existing targets/config only when new scope actually needs it
- `Native/Ambitions/Support/Info.plist`
  - keep permission copy truthful to the surfaces that are actually intended to ship

## Recommended acceptance gates

- Do not plan capture persistence, snapshot export, external routing, notification foundation, EventKit foundation, or reschedule engine work as if they are still missing; those seams already exist in native code.
- Do not claim widget/live-activity/notification/EventKit behavior is production-ready without manual validation.
- Do not start Share Extension or App Intents work by bypassing the existing capture and routing boundaries.
- Do not start sync implementation until the backend decision is documented.
- Do not treat old Supabase docs as live-native product truth.
- Keep all new shipping work inside `Native/Ambitions/`, `Sources/`, `AppUI/Sources/`, or new native extension folders added through `project.yml`.

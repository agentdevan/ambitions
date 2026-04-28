# Ambitions Implementation Backlog

This backlog translates the current roadmap into implementation work that matches the live native codebase in `Native/Ambitions/`.

## Precedence notice

This backlog is supporting context.
It does not override [codex/CONTEXT_INDEX.md](codex/CONTEXT_INDEX.md), [../MASTER_PRODUCT_SPEC.md](../MASTER_PRODUCT_SPEC.md), or the canonical planning docs under [canon](canon).
When this backlog conflicts with the canonical platform vision, surgical execution order, or batch plan, follow the canonical planning stack and update this backlog later.

## Current repo truth

- The shipping product is the native SwiftUI app.
- The live native target is local-first and on-device first.
- The active Ambitions 2.0 shell canon is Today / Goals / Capture / Plan / You. Older code and historical notes may still use Captures, Habits, Insights, or Profile compatibility naming, but those are not active top-level IA promises.
- The active design source of truth is [canon/design/Ambitions_Design_Constitution.md](canon/design/Ambitions_Design_Constitution.md).
- Shared object terminology is locked in [canon/Ambitions_2_0_Object_Terminology.md](canon/Ambitions_2_0_Object_Terminology.md).
- Active canon treats Insights as contextual intelligence, Habits as absorbed into Rituals/Plan/Today/You, Profile as user-facing You, and Tasks as standalone One-Step Goals rather than a top-level Tasks tab.
- `project.yml` currently defines the `Ambitions` app target, the `AmbitionsWidgetExtension` target, and the unit/UI test bundles.
- The current native codebase already includes capture persistence, create-goal submission, external routing, snapshot export, local notification scheduling, EventKit integration, and widget/live-activity code paths.
- The repo no longer retains an active TypeScript / Expo / React Native runtime path.
- Account sync, auth, and backend-driven account deletion are not current shipping features.

## Roadmap mismatches against the current codebase

### 1. Sync is treated as a late-phase add, and backend/provider-specific assumptions must stay out of active repo truth

Why this matters:
- The README and Profile service both describe the native app as local-only today.
- Provider-specific backend/runtime artifacts have been removed from the active repo path.
- Any implementation plan that reintroduces backend-specific assumptions before a sync decision will create new source-of-truth drift.

Backlog impact:
- Keep documentation and planning native-first until a sync decision is made.
- Do not restore provider-specific backend docs or runtime paths without an explicit later batch.

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
- Keep backend/sync notes boundary-level and provider-agnostic until a native sync decision exists.
- Keep implementation docs aligned with the current native service, routing, capture, and extension boundaries.
- Remove ambiguity about what is implemented versus what has merely been scaffolded.
- Keep active docs aligned to the Design Constitution before implementation batches consume the contracts.

Deliverables:
- `docs/README.md`
- status note that legacy runtime/backend artifacts are no longer part of the active repo path
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

### Phase C. Design Constitution implementation follow-through

Goals:
- Implement Life Areas Overview / Atlas, North Stars, One-Step Goals, Smart Attachment, You Personal System Center, GroupedNavigationList, Panel Size + Display Density, Screen Contract Matrix, Component Contract Matrix, Trust Center / What Ambitions Knows, external surface contracts, and Accessibility Nutrition verification in their owning future batches.
- Preserve the current shell and do not create top-level Insights, Profile, Habits, or Tasks tabs.
- Keep calendar permission Plan-owned and onboarding free of upfront permission requests.

Deliverables:
- targeted implementation in owning future batches only
- updated tests and validation evidence per batch
- user-facing claims only when repo evidence supports them

### Phase D. Sync decision and historical-doc containment

Goals:
- Make an explicit native sync decision before any provider-specific implementation resumes.
- Keep backend/provider-specific work out of the active repo until that decision changes.

Deliverables:
- documented sync decision
- explicit boundary language for any future backend revival

## Proposed implementation order

1. Canon and source-of-truth cleanup.
2. Shared object model terminology and docs.
3. Shared component primitives.
4. GroupedNavigationList foundation.
5. Panel Size + Display Density foundation.
6. Receipt / Action Closure design contract.
7. Smart Attachment design/data contract.
8. Life Areas / North Stars object model.
9. One-Step Goals object model.
10. Screen contract implementation pass.
11. Today surface transformation.
12. Capture surface transformation.
13. Goals / Life Areas / North Stars transformation.
14. Plan / Timeline / Rituals transformation.
15. You Personal System Center transformation.
16. Trust Center / What Ambitions Knows.
17. Accessibility Nutrition verification.
18. External surfaces: widgets, Live Activities, App Intents.
19. Release-candidate validation.

Existing native foundations should be validated as they are consumed by the sequence above. Do not recreate capture persistence, notification foundation, EventKit preparation, external routing, widget/live-activity scaffolding, or reschedule infrastructure as greenfield work. Decide sync before reviving backend/provider-specific work.

## Post-audit delta batches

The repo-wide gap audit is [canon/Ambitions_2_0_Implementation_Gap_Audit.md](canon/Ambitions_2_0_Implementation_Gap_Audit.md). It confirms that existing foundations should be preserved, but several completed historical surfaces need new Constitution-alignment batches. These are planned future work only.

Recommended delta order:

1. Shell IA / Tab Alignment Delta.
2. Shared Object Terminology Cleanup.
3. GroupedNavigationList Component.
4. Panel Size + Display Density.
5. Receipt / Action Closure Search and Privacy Contract.
6. Smart Attachment Foundation.
7. Life Areas Overview / Atlas Object Model.
8. North Stars / Dormant Ambitions Object Model.
9. One-Step Goals Object Model.
10. Screen Contract Matrix Implementation Pass.
11. Today 2.0 Design Constitution Alignment.
12. Capture + Quiet Command Sheet Alignment.
13. Goals / Life Areas / North Stars Transformation and Semantic Zoom.
14. Goal Detail Mission Control Lanes Alignment.
15. Plan Believability + Timeline Widget Alignment.
16. Ritual Split Alignment.
17. You Personal System Center Alignment.
18. Trust Center Alignment.
19. What Ambitions Knows.
20. UX Writing Cleanup.
21. Accessibility Nutrition Verification.
22. External Surfaces Contract Alignment.
23. Widgets Alignment.
24. Live Activities Alignment.
25. App Intents / Shortcuts Alignment.
26. Release Candidate Validation.

The exact recommended next implementation batch after D02 is `GroupedNavigationList Component`. D01 shell alignment and D02 shared object terminology cleanup are complete for planning purposes, so the next dependency-safe foundation is the grouped list and row taxonomy needed by later You, Trust, Memory, Goal Detail, and Plan control surfaces.

## Roadmap merge audit note

[canon/Ambitions_2_0_Roadmap_Merge_Audit.md](canon/Ambitions_2_0_Roadmap_Merge_Audit.md) maps the original Batches 89-120 against D01-D26. D01-D26 take precedence wherever old roadmap wording conflicts with the Design Constitution. Original Batch 89-120 work remains preserved future intent only where resequenced, absorbed, deferred, or rewritten by that audit.

Do not start Batch 89 as the next implementation batch unless a future user instruction explicitly overrides the D backlog and the merge audit dependency gates. The dependency-safe next implementation batch after D02 is D03.

## Design Constitution Coverage Checklist

The backlog now tracks the following as future implementation coverage, not shipped proof: Life Areas Overview / Atlas, North Stars / dormant Ambitions, One-Step Goals, Task/Step distinction, Smart Attachment with receipts/correction, You Personal System Center, Trust Center, What Ambitions Knows, GroupedNavigationList, Panel Size, Display Density, screen/component/UX writing matrices, Accessibility Nutrition verification, external surfaces contract, widgets, Live Activities, App Intents/Shortcuts, notification frequency/privacy controls, receipt search/history, local-first calendar-derived insight, Plan-owned calendar permission, motion/Reduce Motion, Semantic Zoom fallbacks, safe-zone modularity, Today Plan Layer, and Life Areas / North Stars / Goals semantic zoom.

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
  - compatibility folder may host user-facing You surfaces until renamed by an owning batch
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
- Do not treat backend/provider-specific runtime work as live-native product truth before a sync decision.
- Keep all new shipping work inside `Native/Ambitions/`, `Sources/`, `AppUI/Sources/`, or new native extension folders added through `project.yml`.

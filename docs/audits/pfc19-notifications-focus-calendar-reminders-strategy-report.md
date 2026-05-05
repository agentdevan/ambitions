# PFC19 Notifications / Focus / Calendar / Reminders Strategy Report
<!-- markdownlint-disable MD013 -->

Date: 2026-05-05
Result: Green
Train: PFC Platform / Framework / Compliance Completion
Batch ID: PFC19

## Result

PFC19 completed as docs/product/platform strategy. It defines the notification,
Focus, Calendar, Reminders, EventKit, permission-copy, privacy, accessibility,
and performance boundaries for later PFC20 proof or implementation.

## Source Truth Used

- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/canon/Ambitions_Notifications_Focus_Calendar_Reminders_Strategy.md`
- `docs/canon/TRUST_PRIVACY_MEMORY.md`
- `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
- `docs/audits/ambitions-3-0-f20-external-surfaces-privacy-projection-report.md`
- `docs/audits/ambitions-3-0-f24-privacy-trust-qa-report.md`
- `docs/audits/cs07-external-route-widget-appintent-compatibility-proof-report.md`
- `docs/audits/fvq05-final-visual-proof-packet-integration-report.md`
- `docs/audits/visual-evidence/fvq05/final-visual-proof-packet.md`

## Files Read

- `Native/Ambitions/Notifications/LocalNotificationFoundation.swift`
- `Native/Ambitions/Notifications/NotificationRuntime.swift`
- `Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift`
- `Native/Ambitions/Features/Plan/PlanCalendarAwarenessSupport.swift`
- `Native/AmbitionsTests/App/LocalNotificationFoundationTests.swift`
- `Native/AmbitionsTests/App/NotificationResponsePayloadParserTests.swift`
- `Native/AmbitionsTests/App/EventKitIntegrationServiceTests.swift`
- `Native/AmbitionsTests/App/CalendarReminderActionFlowTests.swift`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Files Changed

- `docs/canon/Ambitions_Notifications_Focus_Calendar_Reminders_Strategy.md`
- `docs/audits/pfc19-notifications-focus-calendar-reminders-strategy-report.md`
- global order, optimized order, dependency graph, registry, context, PFC train,
  and run-state docs

## What Changed

- Defined the integration decision record for notifications, notification
  actions, system Focus surfaces, Calendar read, Calendar write, Reminders
  write, and Calendar-derived memory.
- Locked notification permission copy to explicit opt-in, privacy-safe, and
  non-pressure language.
- Locked Calendar permission copy to Plan-owned explicit action and denied-state
  fallback language.
- Deferred Focus Filter implementation and Calendar-derived memory.
- Required PFC20 proof before any implementation or readiness claim.
- Advanced global state from PFC19 queued to PFC19 Green and selected PFC21 as
  the next eligible global batch.

## Why

The repo already contains local notification and EventKit source plus focused
tests. PFC19 gives later platform work a safe decision boundary: notifications
must be sparse and opt-in, Calendar remains Plan-owned, Reminders require an
explicit user action, and Focus integration is deferred unless separately
proved.

## Alternatives Considered

- Requesting notification or Calendar permission during onboarding was rejected
  because Ambitions must provide value before permission prompts.
- Direct notification mutation was rejected because consequential changes need
  in-app confirmation and receipt proof.
- Launch Focus Filter integration was rejected because no scoped implementation
  or platform proof exists.
- Broad Calendar/Reminders mirroring was rejected because Plan must remain
  LifeShape-first and user-controlled.

## Product Decisions Preserved

- Top-level tabs remain Today / Goals / Capture / Plan / You.
- Capture remains text-first.
- Plan remains LifeShape-first and owns Calendar/availability boundaries.
- You remains trust/control-first.
- Notifications remain operational and sparse, not a receipt posture.
- Calendar access remains optional and Plan-owned.
- Privacy remains user control, not external-surface exposure.
- No route/raw value, persistence/schema, sync/account, AI runtime, LDI runtime,
  permission prompt, entitlement, signing, legal/privacy, App Store, TestFlight,
  release, physical-device, or public accessibility claim was added.

## Caveats Preserved

- Notification readiness remains conditional.
- Existing notification and EventKit code is not claimed release-ready.
- Focus Filter integration remains deferred.
- Calendar-derived memory remains deferred and confirmation-gated.
- Physical-device, signed-archive, App Store, TestFlight, public accessibility,
  and legal/privacy proof remain human/operator-owned.

## Candidate Items Touched Or Avoided

No Candidate item was finalized. PFC19 defines strategy and allowed/deferred
integration boundaries only.

## CQS Reviewers Applied

- Platform surface reviewer: integration set is bounded and permissioned.
- Privacy/legal/App Store reviewer: no release or compliance claim added.
- Accessibility / Reduced Motion reviewer: future spoken/visible permission and
  confirmation proof requirements named.
- Performance/battery reviewer: no broad refresh or background scan approved.
- Product canon drift reviewer: no calendar-first or notification-heavy product
  posture approved.

## AQOS Impact Classification

Docs/product/platform strategy. Required evidence is source-truth consistency,
current source inventory, privacy no-claim boundary, future proof requirements,
order integration, and docs validation.

## FVQ Rendered Proof Classification

Operator checklist required later for notification content, platform permission
surfaces, Calendar confirmation, and any system Focus presentation. PFC19 itself
changes no visible UI and uses FVQ05 to carry missing external-surface rendered
proof as Yellow-owned.

## Accessibility / Reduced Motion Impact

No runtime accessibility or motion behavior changed. PFC19 requires future
notification action labels, permission copy, VoiceOver, Dynamic Type, non-color
meaning, Reduce Motion, and privacy-safe spoken text proof before implementation
readiness.

## Privacy / Legal / App Store Impact

No privacy/legal/App Store behavior or claim changed. PFC19 strengthens the
permission and no-hidden-mutation boundary for notifications, Calendar,
Reminders, and Focus-related platform surfaces.

## Performance / Battery Impact

No runtime performance or battery behavior changed. PFC19 requires no
high-frequency notification refresh loop, no broad calendar scan, bounded
EventKit fetch windows, no heavy notification handling, no network dependency,
and safe local failure proof before implementation claim.

## Validation Commands

- `git status --short`
- `git diff --check`
- touched-file trailing whitespace scan
- `scripts/cqs-product-drift-scan.sh ... || true`
- `scripts/cqs-accessibility-motion-scan.sh ... || true`
- `scripts/cqs-privacy-security-claim-scan.sh ... || true`
- `scripts/cqs-performance-budget-scan.sh ... || true`
- `scripts/run-doc-qa.sh || true`
- `scripts/batch-train-gate-check.sh || true`

## Validation Results

- `git status --short`: showed only PFC19 docs/train-state changes before
  commit.
- `git diff --check`: passed.
- touched-file trailing whitespace scan: passed.
- `scripts/cqs-product-drift-scan.sh ... || true`: passed with
  `CQS_PRODUCT_DRIFT_HITS=0`.
- `scripts/cqs-accessibility-motion-scan.sh ... || true`: passed with
  `CQS_ACCESSIBILITY_MOTION_HITS=0`.
- `scripts/cqs-privacy-security-claim-scan.sh ... || true`: passed with
  `CQS_PRIVACY_SECURITY_CLAIM_HITS=0`.
- `scripts/cqs-performance-budget-scan.sh ... || true`: passed with
  `CQS_PERFORMANCE_BUDGET_HITS=0`.
- `scripts/run-doc-qa.sh || true`: advisory backlog remained in stale-guidance,
  deprecated-language, and markdownlint logs; lychee reported `650 OK` and
  `0 Errors`.
- `scripts/batch-train-gate-check.sh || true`: expected Yellow dirty-worktree
  hint before commit; no Hard Red.

## Repairs Attempted

None required.

## Remaining Yellow Items

- No physical notification delivery proof.
- No Focus Filter implementation/proof.
- No physical-device Calendar/Reminders proof.
- No signed-archive/App Store/TestFlight proof.
- No public accessibility conformance proof.
- No legal/privacy signoff.
- PFC20 implementation remains future and conditional.
- Existing doc QA advisory backlog may remain.

## Red Classification

No Recoverable Red or Hard Red found during implementation.

## Rollback Path

Revert the PFC19 commit to remove the Notifications / Focus / Calendar /
Reminders strategy and restore PFC19 to queued in global order, registry,
context, PFC train, and run-state docs.

## Next Eligible Batch

PFC21 StoreKit / Monetization Strategy is next under full-stack order.

## Continuation Decision

PFC19 may continue to PFC21 after validation passes and the batch is committed
and pushed.

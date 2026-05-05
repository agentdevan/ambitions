# PFC15 Live Activities / ActivityKit Strategy Report
<!-- markdownlint-disable MD013 -->

Date: 2026-05-05
Result: Green
Train: PFC Platform / Framework / Compliance Completion
Batch ID: PFC15

## Result

PFC15 completed as docs/product/platform strategy. It defines the only allowed
Live Activity launch candidate, defers all broader candidates, and keeps Lock
Screen / Dynamic Island proof claims blocked until implementation, rendering,
device, accessibility, privacy, and human-proof gates exist.

## Source Truth Used

- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/canon/EXTERNAL_SURFACES_NOTIFICATIONS_WIDGETS.md`
- `docs/canon/Ambitions_2_0_Capability_Matrix.md`
- `docs/audits/ambitions-3-0-f20-external-surfaces-privacy-projection-report.md`
- `docs/audits/ambitions-3-0-f24-privacy-trust-qa-report.md`
- `docs/audits/cs07-external-route-widget-appintent-compatibility-proof-report.md`
- `docs/audits/fvq05-final-visual-proof-packet-integration-report.md`
- `docs/audits/visual-evidence/fvq05/final-visual-proof-packet.md`

## Files Read

- `Native/Ambitions/ExternalSnapshots/NextStepActivityAttributes.swift`
- `Native/Ambitions/Notifications/NextStepLiveActivityService.swift`
- `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Files Changed

- `docs/canon/Ambitions_Live_Activities_ActivityKit_Strategy.md`
- `docs/audits/pfc15-live-activities-activitykit-strategy-report.md`
- global order, optimized order, dependency graph, registry, context, PFC train,
  and run-state docs

## What Changed

- Defined `Active Step Focus Window` as the only allowed future launch candidate.
- Deferred Step Session timer, protected block, recovery window, and
  commute/travel Live Activities until named owner/proof batches.
- Explicitly disallowed broad day/goal/review surfaces, sensitive Lock Screen
  content, ads, promotion, and background-intelligence claims.
- Documented start/update/end/stale rules, privacy rules, accessibility /
  Reduce Motion requirements, performance/battery boundaries, and PFC16 proof
  requirements.
- Advanced global state from PFC15 queued to PFC15 Green and selected PFC17 as
  the next eligible global batch.

## Why

The repo already contains ActivityKit source and privacy-safe projection proof,
but release/platform claims still need platform rendering and device proof.
PFC15 gives PFC16 a safe decision boundary without widening Ambitions into a
Lock Screen surface for everything happening in the app.

## Alternatives Considered

- `No Live Activity` remains the safe fallback if proof gates fail later.
- Step Session timer was not selected as default because the Product Experience
  Pack keeps the timer secondary.
- Protected block and recovery window were deferred because they require stronger
  Plan/Recovery owner proof before Lock Screen exposure.
- Commute/travel was deferred because it can imply location/calendar behavior
  that is not launch-proved.

## Product Decisions Preserved

- Top-level tabs remain Today / Goals / Capture / Plan / You.
- Capture remains text-first.
- Plan remains LifeShape-first and owns calendar/availability boundaries.
- You remains trust/control-first.
- Step Session timer remains secondary.
- Privacy remains user control, not external-surface exposure.
- No route/raw value, persistence/schema, sync/account, AI runtime, LDI runtime,
  calendar write, permission prompt, legal/privacy, App Store, TestFlight,
  release, physical-device, or public accessibility claim was added.

## Caveats Preserved

- Live Activity readiness remains conditional.
- Existing ActivityKit code is not claimed release-ready.
- Lock Screen / Dynamic Island rendering remains unproved.
- Physical-device, signed-archive, App Store, TestFlight, public accessibility,
  and legal/privacy proof remain human/operator-owned.

## Candidate Items Touched Or Avoided

No Candidate item was finalized. PFC15 defines strategy and allowed/deferred
candidate boundaries only.

## CQS Reviewers Applied

- Platform surface reviewer: allowed candidate is bounded and privacy-safe.
- Privacy/legal/App Store reviewer: no release or compliance claim added.
- Accessibility / Reduced Motion reviewer: future proof requirements named.
- Performance/battery reviewer: update budget and proof requirements named.
- Product canon drift reviewer: no broad Lock Screen control surface or broad
  goal/day surface approved.

## AQOS Impact Classification

Docs/product/platform strategy. Required evidence is source-truth consistency,
current source inventory, privacy no-claim boundary, future proof requirements,
order integration, and docs validation.

## FVQ Rendered Proof Classification

Operator checklist required later. PFC15 itself changes no visible UI and uses
FVQ05 to carry missing widget/Live Activity rendered proof as Yellow-owned.

## Accessibility / Reduced Motion Impact

No runtime accessibility or motion behavior changed. PFC15 requires future
Dynamic Type, VoiceOver, non-color meaning, Reduce Motion, Lock Screen, and
Dynamic Island readability proof before implementation readiness.

## Privacy / Legal / App Store Impact

No privacy/legal/App Store behavior or claim changed. PFC15 strengthens the
no-sensitive-Lock-Screen boundary and keeps legal/privacy/App Store/TestFlight/
release claims unmade.

## Performance / Battery Impact

No runtime performance or battery behavior changed. PFC15 requires bounded
update cadence, snapshot precomputation, Live Activity update budget, and
battery/thermal proof or human/device proof stop before implementation claim.

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

- `git status --short`: showed only PFC15 docs/train-state changes before
  commit.
- `git diff --check`: passed.
- touched-file trailing whitespace scan: passed.
- `scripts/cqs-product-drift-scan.sh ... || true`: repaired one report-only
  self-hit from negative guardrail wording, then passed with
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

- Reworded the report's negative product-drift guardrail line so the CQS
  product drift scanner no longer self-hit on a forbidden drift term.

## Remaining Yellow Items

- No rendered Lock Screen / Dynamic Island proof.
- No physical-device ActivityKit lifecycle proof.
- No signed-archive/App Store/TestFlight proof.
- No public accessibility conformance proof.
- No legal/privacy signoff.
- PFC16 implementation remains future and conditional.
- Existing doc QA advisory backlog may remain.

## Red Classification

No Recoverable Red or Hard Red found during implementation.

## Rollback Path

Revert the PFC15 commit to remove the ActivityKit strategy and restore PFC15 to
queued in global order, registry, context, PFC train, and run-state docs.

## Next Eligible Batch

PFC17 App Intents / Shortcuts / Spotlight Strategy is next under full-stack
order.

## Continuation Decision

PFC15 may continue to PFC17 after validation passes and the batch is committed
and pushed.

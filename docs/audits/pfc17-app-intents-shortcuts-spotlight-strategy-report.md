# PFC17 App Intents / Shortcuts / Spotlight Strategy Report
<!-- markdownlint-disable MD013 -->

Date: 2026-05-05
Result: Green
Train: PFC Platform / Framework / Compliance Completion
Batch ID: PFC17

## Result

PFC17 completed as docs/product/platform strategy. It defines the allowed
App Intent / Shortcut launch candidate set, blocks external hidden mutation,
keeps Spotlight indexing off by default, and reserves implementation/proof for
PFC18 or later scoped platform batches.

## Source Truth Used

- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/canon/Ambitions_App_Intents_Shortcuts_Spotlight_Strategy.md`
- `docs/canon/EXTERNAL_SURFACES_NOTIFICATIONS_WIDGETS.md`
- `docs/canon/Ambitions_2_0_Implementation_Gap_Audit.md`
- `docs/audits/ambitions-3-0-f24-privacy-trust-qa-report.md`
- `docs/audits/cs07-external-route-widget-appintent-compatibility-proof-report.md`
- `docs/audits/fvq05-final-visual-proof-packet-integration-report.md`
- `docs/audits/visual-evidence/fvq05/final-visual-proof-packet.md`

## Files Read

- `Native/Ambitions/AppIntents/OpenAmbitionsDestinationIntent.swift`
- `Native/Ambitions/App/AppIntentLaunchRouter.swift`
- `Native/Ambitions/App/AppExternalRouting.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceContractModels.swift`
- `Native/Ambitions/Support/ExternalSurfaceVerificationChecklist.swift`
- `Native/AmbitionsTests/App/AppIntentRoutingTests.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceActionPayloadTests.swift`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/codex/GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`
- `docs/codex/GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Files Changed

- `docs/canon/Ambitions_App_Intents_Shortcuts_Spotlight_Strategy.md`
- `docs/audits/pfc17-app-intents-shortcuts-spotlight-strategy-report.md`
- global order, optimized order, dependency graph, registry, context, PFC train,
  and run-state docs

## What Changed

- Defined the allowed future App Intent / Shortcut launch candidate set:
  Capture text, Open Today, Open Plan, Open Capture, Add something, What
  Ambitions Knows, Start here, Close the loop, and Make today doable.
- Classified existing compatibility destinations as internal route compatibility
  that must not widen the public launch contract without a named proof batch.
- Required in-app confirmation for completion, recovery, plan edits,
  calendar/reminder effects, deletion, or any consequential mutation.
- Set launch Spotlight/CoreSpotlight indexing to not approved by default.
- Documented privacy, accessibility, performance, and PFC18 proof boundaries.
- Advanced global state from PFC17 queued to PFC17 Green and selected PFC19 as
  the next eligible global batch.

## Why

The repo already has App Intent and Shortcut source plus simulator/unit route
and privacy tests. It does not have device Shortcuts/Siri proof or Spotlight
indexing proof. PFC17 makes the public platform boundary explicit before any
future PFC18 implementation or proof batch touches App Intent behavior.

## Alternatives Considered

- Full Spotlight indexing was rejected for launch default because it could
  expose private life content and no CoreSpotlight implementation/proof exists.
- Direct external completion or recovery was rejected because user confirmation
  and receipt generation must happen inside Ambitions.
- Private memory/receipt search was deferred because You / Privacy / Memory /
  Receipts remain copy-density guarded and privacy-sensitive.

## Product Decisions Preserved

- Top-level tabs remain Today / Goals / Capture / Plan / You.
- Capture remains text-first.
- Placement appears only after content exists.
- Plan remains LifeShape-first and owns calendar/availability boundaries.
- You remains trust/control-first.
- Privacy remains user control, not external-surface exposure.
- Receipts remain consequence/reversibility, not notifications.
- No route/raw value, persistence/schema, sync/account, AI runtime, LDI runtime,
  calendar/reminder write, permission prompt, legal/privacy, App Store,
  TestFlight, release, physical-device, or public accessibility claim was added.

## Caveats Preserved

- App Intent / Shortcut readiness remains conditional.
- Existing App Intent code is not claimed release-ready.
- Shortcuts/Siri device invocation remains unproved.
- Spotlight/CoreSpotlight indexing is not launch-approved by default.
- Physical-device, signed-archive, App Store, TestFlight, public accessibility,
  and legal/privacy proof remain human/operator-owned.

## Candidate Items Touched Or Avoided

No Candidate item was finalized. PFC17 defines strategy and allowed/deferred
candidate boundaries only.

## CQS Reviewers Applied

- Platform surface reviewer: allowed command set is bounded.
- Privacy/legal/App Store reviewer: no release or compliance claim added.
- Accessibility / Reduced Motion reviewer: future spoken/visible confirmation
  proof requirements named.
- Performance/battery reviewer: no indexing/update loop approved by default.
- Product canon drift reviewer: no hidden mutation or new destination approved.

## AQOS Impact Classification

Docs/product/platform strategy. Required evidence is source-truth consistency,
current source inventory, privacy no-claim boundary, future proof requirements,
order integration, and docs validation.

## FVQ Rendered Proof Classification

Operator checklist required later for any visible Shortcuts/Siri/App Intent
confirmation or Spotlight system presentation. PFC17 itself changes no visible
UI and uses FVQ05 to carry missing external-surface rendered proof as
Yellow-owned.

## Accessibility / Reduced Motion Impact

No runtime accessibility or motion behavior changed. PFC17 requires future
parameter label, result dialog, VoiceOver, Dynamic Type, non-color meaning, and
privacy-safe spoken text proof before implementation readiness.

## Privacy / Legal / App Store Impact

No privacy/legal/App Store behavior or claim changed. PFC17 strengthens the
no-hidden-mutation boundary and keeps Spotlight indexing off by default.

## Performance / Battery Impact

No runtime performance or battery behavior changed. PFC17 requires no broad
background indexing loop, lightweight route payload creation, no heavy intent
execution, no network dependency, and safe local failure proof before
implementation claim.

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

- `git status --short`: showed only PFC17 docs/train-state changes before
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

- No real Shortcuts/Siri invocation proof.
- No Spotlight/CoreSpotlight proof.
- No physical-device proof.
- No signed-archive/App Store/TestFlight proof.
- No public accessibility conformance proof.
- No legal/privacy signoff.
- PFC18 implementation remains future and conditional.
- Existing doc QA advisory backlog may remain.

## Red Classification

No Recoverable Red or Hard Red found during implementation.

## Rollback Path

Revert the PFC17 commit to remove the App Intents / Shortcuts / Spotlight
strategy and restore PFC17 to queued in global order, registry, context, PFC
train, and run-state docs.

## Next Eligible Batch

PFC19 Notifications / Focus / Calendar / Reminders Integration Strategy is next
under full-stack order.

## Continuation Decision

PFC17 may continue to PFC19 after validation passes and the batch is committed
and pushed.

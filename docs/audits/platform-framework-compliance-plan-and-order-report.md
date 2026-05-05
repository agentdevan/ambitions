# Platform / Framework / Compliance Plan And Order Report
<!-- markdownlint-disable MD013 -->

Result: PASS WITH ACCEPTED YELLOW
Date: 2026-05-05
Scope: Docs-only source-truth and global order update

## Task

Expand Ambitions completion planning beyond user-facing product objects to cover every non-user-facing domain required for a true FAANG-level app and repo handoff, including Live Activities, widgets, iCloud sync, monetization, architecture, schema, performance, data freshness, legal/privacy, security, release engineering, observability, and repo cleanliness.

## Files Created

- `docs/canon/Ambitions_Platform_Legal_And_Framework_Completion_Plan.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`
- `docs/audits/platform-framework-compliance-plan-and-order-report.md`

## Files Updated

- `docs/codex/GLOBAL_BATCH_EXECUTION_ORCHESTRATOR.md`

## External Research Inputs

Current Apple/platform requirements were checked at a high level before creating the plan. The plan reflects these constraints:

- WidgetKit and ActivityKit surfaces must be constrained, glanceable, privacy-safe, and deep-link to relevant app context.
- CloudKit/iCloud sync must have explicit container/schema/conflict/offline/local-only behavior.
- StoreKit monetization requires entitlement/restoration/testing and App Review-safe paywall posture.
- App privacy labels and required-reason API privacy manifests must match actual app and third-party SDK behavior.
- Legal compliance cannot be self-certified by Codex; human legal/privacy review is a required proof stop.

## Core Change

The repo now has a new train:

`PFC01-PFC40 Platform / Framework / Compliance Completion Train`

PFC covers:

- repo/build system cleanliness
- architecture/framework boundaries
- dead code and prompt-built smell removal
- dependencies/supply chain/licenses
- CI/local reproducibility
- persistence/schema/migration
- corruption/backup/restore
- iCloud/CloudKit sync
- App Groups/shared storage
- WidgetKit
- Live Activities/ActivityKit
- App Intents/Shortcuts/Spotlight
- notifications/Focus/Calendar/Reminders
- StoreKit/monetization/paywall compliance
- privacy data map/App Store privacy labels
- privacy manifest/required-reason API audit
- terms/privacy/legal review packet
- safety/professional/crisis boundaries
- security threat model/secrets audit
- logging/analytics/observability
- performance/battery/Instruments plan and repairs
- accessibility across external surfaces
- data freshness/stale-state gates
- App Store metadata/claim truth
- release engineering/TestFlight plan
- FAANG handoff architecture packet
- repo hygiene and prompt-built smell removal
- full platform/legal/framework audit
- final PFC handoff

## Global Order Change

The repo now has a highest-priority global order overlay:

`docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`

The orchestrator now selects from this file before `GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`.

## Why This Was Needed

The previous FCP/FCP+AOS/LDI plan could produce a beautiful and coherent product surface, but it did not fully guarantee:

- clean schema and migrations
- iCloud sync safety
- widget/Live Activity quality
- StoreKit entitlement correctness
- legal/privacy/App Store readiness
- performance and battery proof
- observability/privacy discipline
- release engineering maturity
- FAANG handoff readability
- removal of prompt-built repo smell

PFC closes that gap.

## No-Claim Boundaries

This docs-only update does not claim:

- any PFC batch is implemented
- iCloud sync is implemented
- widgets are implemented
- Live Activities are implemented
- App Intents are implemented
- notifications/Calendar/Reminders are implemented
- StoreKit monetization is implemented
- privacy labels or privacy manifests are final
- legal compliance is achieved
- App Store/TestFlight/release readiness exists
- physical-device/public accessibility/performance proof exists
- FAANG handoff readiness exists

## Validation

This update was performed through the GitHub connector. Local shell validation was not available in this session, so the following were not run here:

- `git status --short`
- `git diff --check`
- `scripts/run-doc-qa.sh`
- `scripts/batch-train-gate-check.sh`

The update remained docs-only and did not edit production Swift, route/raw values, persistence/schema, dependencies, workflows, signing, entitlements, generated project files, or CI.

## Accepted Yellow Items

- Local doc QA and batch-gate scripts were not run in this remote connector session.
- Registry/context/run-state files still require local reconciliation because they are large and should not be blindly overwritten through connector-truncated reads.
- PFC prompts are train-level; individual per-batch implementation prompts can be generated later if Codex needs one-file-per-batch prompts.

## Recommended Next Local Reconciliation

Update the existing reconciliation prompt or run a local reconciliation that adds:

- `docs/canon/Ambitions_Platform_Legal_And_Framework_Completion_Plan.md`
- `docs/codex/batch-trains/PFC01_PFC40_PLATFORM_FRAMEWORK_COMPLIANCE_TRAIN.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md`

into:

- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `.codex/reports/current-run-state.md`
- `.codex/reports/current-batch-train-state.md`

## Next Eligible Batch After Reconciliation

Using the full-stack order, the next eligible work is:

1. FCP registry/context reconciliation, expanded to include PFC and full-stack order.
2. FCP/PFC source-truth foundation batches.
3. PD15 once reconciliation/source-truth setup is clean.

Implementation remains single-batch and gate-bound.

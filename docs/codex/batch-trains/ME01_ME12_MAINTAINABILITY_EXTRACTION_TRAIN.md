# ME01-ME12 Maintainability Extraction Train

Status: Future train manifest; not started automatically

## Start Rule

This train starts only when the user explicitly approves it after Ambitions 3.0/F17-F30 truth is Green and `docs/codex/BATCH_REGISTRY.md` records the selected train as active. Required user approval phrase: `Start ME01 Maintainability Baseline And Ownership Map`.

## What Does Not Start This Train

Reading this manifest, updating future canon, completing AmbitionsOS docs, finishing F30, or selecting a roadmap lane does not start the train. AOS/ME/CS/Product Depth/Release Evidence Closure do not start each other by implication.

## Historical Truth To Preserve

Ambitions 3.0 is complete by F30 closeout evidence. F17-F30 remains a complete historical train. AmbitionsOS remains future canon until implementation evidence exists. Release, App Store, TestFlight, physical-device, public accessibility, signed archive, App Store Connect, and rendered external-platform claims remain unmade unless a later train produces proof.

## Train Safety Gates

- Batch order is sequential unless this manifest names an explicit dependency exception.
- Green may continue only after evidence, report, registry/context/run-state update, commit, and push.
- Yellow stops unless the manifest says the next batch may proceed with documented risk.
- Red stops immediately and opens a repair or user-decision prompt.
- Build/test requirements are batch-specific: docs-only batches use doc and registry checks; app-code batches require focused tests and advisory build at minimum; release-claim batches require evidence-ledger proof and explicit claim review.
- No second batch starts from this manifest unless the active batch is Green and train rules allow continuation.
- Repair-train triggers: unclassified validation failure, forbidden file drift, claim overreach, privacy/source/compatibility uncertainty, or behavior regression.
- Every batch must be committed before continuation.

## File Boundaries

Allowed files are the files named by each batch prompt. Forbidden across the train: `.github/workflows/**`, dependencies, lockfiles, signing/project release config, persistence/schema files unless a migration batch explicitly owns them, broad app refactors, new top-level navigation, backend/sync/account/telemetry/runtime AI additions, and release/platform claims without evidence.

## Batch Order And Gates

- ME01: Maintainability Baseline And Ownership Map. Mode: audit only. Owner: all Lane 2 candidate files. Gate: behavior preservation before extraction, no product expansion.
- ME02: GoalsFeatureService Extraction. Mode: extraction only. Owner: Native/Ambitions/Features/Goals/GoalsFeatureService.swift. Gate: behavior preservation before extraction, no product expansion.
- ME03: TodayFeatureService Extraction. Mode: extraction only. Owner: Native/Ambitions/Features/Today/TodayFeatureService.swift. Gate: behavior preservation before extraction, no product expansion.
- ME04: TodayPanels Extraction. Mode: extraction only. Owner: Native/Ambitions/Features/Today/TodayPanels.swift. Gate: behavior preservation before extraction, no product expansion.
- ME05: PlanFeatureService Extraction. Mode: extraction only. Owner: Native/Ambitions/Features/Plan/PlanFeatureService.swift. Gate: behavior preservation before extraction, no product expansion.
- ME06: ProfileScreen You Surface Extraction. Mode: extraction only. Owner: Native/Ambitions/Features/Profile/ProfileScreen.swift. Gate: behavior preservation before extraction, no product expansion.
- ME07: PlanScreen Extraction. Mode: extraction only. Owner: Native/Ambitions/Features/Plan/PlanScreen.swift. Gate: behavior preservation before extraction, no product expansion.
- ME08: Shared Projector State Helper Standards. Mode: audit only. Owner: Native/Ambitions/Features/** and shared UI helpers selected by ME01. Gate: behavior preservation before extraction, no product expansion.
- ME09: Product Contract Test Rebaseline. Mode: test rebaseline only. Owner: tests covering ME01-ME08 owner files. Gate: behavior preservation before extraction, no product expansion.
- ME10: Architecture Scan Gate. Mode: audit only. Owner: architecture scan outputs and Lane 2 owner files. Gate: behavior preservation before extraction, no product expansion.
- ME11: Maintainability Regression Repair. Mode: repair only. Owner: files named by failed ME evidence. Gate: behavior preservation before extraction, no product expansion.
- ME12: Maintainability Handoff. Mode: handoff only. Owner: docs/audits, docs/codex, .codex/reports. Gate: behavior preservation before extraction, no product expansion.

## Validation Matrix

Each batch report must include: command evidence, log paths when available, pass/fail/partial status, what the proof covers, what it does not prove, privacy/accessibility/performance/compatibility/release impacts, rollback/repair path, and next allowed batch.

## Auto-Continuation

Auto-continuation is disabled by default. It is allowed only when the active batch is Green, committed, pushed, and the next batch is the direct successor in this manifest. Yellow or Red requires an explicit repair or user-decision prompt.

## Release Claim Boundary

This train does not create release readiness, App Store readiness, TestFlight readiness, final RC lock, physical-device proof, public accessibility conformance, signed archive validation, App Store Connect validation, or rendered external-platform proof unless a batch explicitly produces and records that evidence.

## Closeout

Closeout requires an audit report, registry/context/run-state updates, evidence ledger entry, diff boundary check, and exact next-user-decision statement. ME closeout must also update the maintainability extraction plan, large-file ownership map, and residual debt ledger.

<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-003 - Versioned Runtime Snapshot Ledger

Linear issue: AMB-397
Linear project: Ambitions Flagship Elevation Program
Milestone: Flagship Data Graph and Provenance

## Required Truth And Predecessor Checks

Read these before editing:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`
- `prompts/batches/AFEP-001.md`
- `prompts/batches/AFEP-002.md`
- AFEP-001 and AFEP-002 source, tests, commits, and proof reports
- relevant runtime, receipt, replay, recommendation, persistence, export, and proof files

Confirm AFEP-001 and AFEP-002 are locally Green before source edits. Do not modify, split, rename, or rewrite AFRI-000 through AFRI-040.

## Purpose

Tie every recommendation and proof artifact to one exact, versioned runtime input envelope so receipts, replay, export, and recovery can identify the local-first source context that produced a recommendation or proof artifact.

## Product And Architecture Boundaries

- Preserve canonical IA: Today / Goals / Capture / Time / You.
- Preserve primary objects: Reality Meridian, Constellation Atlas, Atmosphere Composer, LifeShape Field, User System Profile.
- Preserve local-first Private Life Runtime as core architecture.
- Do not add cloud AI, hosted inference, analytics SDKs, backend accounts, custom server infrastructure, hosted CI, signing automation, or paid services.
- Do not claim release readiness, accessibility verification, performance verification, device proof, TestFlight readiness, App Store readiness, privacy/legal approval, or CI proof unless current evidence exists.
- Keep AFRI runtime adapters as the primary rollback path until snapshot-ledger parity is source-backed and proven.
- Runtime snapshot envelopes must be deterministic, inspectable, versioned, export-safe, and privacy-classed.
- Any touched receipt, recommendation, proof, or replay path must preserve explicit `SourceRecord`, `Receipt`, `ReplayTrace`, and AFEP-002 lineage/tombstone boundaries where applicable.
- User-inspectable runtime snapshot history, replay references, and redaction behavior must remain visible through You / What Ambitions knows inspection where the touched owner exposes it.

## Implementation Scope

Implement the smallest source-backed runtime snapshot ledger that satisfies AMB-397:

1. Version the runtime input envelope schema.
2. Add provenance metadata for recommendation and proof inputs.
3. Add redaction classes for snapshot fields.
4. Add compatibility checks for current and older envelope versions.
5. Add replay hooks so receipts and proof artifacts can reference and validate one runtime envelope.

Prefer existing owner seams and names over new broad architecture. Extend current domain, persistence, service, test, and proof owners where appropriate:

- `Native/Ambitions/Domain/`
- `Native/Ambitions/Persistence/`
- `Native/Ambitions/Services/`
- `Native/AmbitionsTests/`
- proof/report files under `build/reports/afep/AFEP-003/` or an equally scoped existing proof root

## Acceptance Gates

- Any receipt can reference one runtime envelope.
- Snapshot schemas are versioned and inspectable.
- Snapshot envelopes include deterministic provenance metadata.
- Sensitive snapshot fields have explicit redaction classes and export behavior.
- Compatibility checks distinguish supported, migrated, and unsupported envelope versions.
- Replay hooks can validate a current proof artifact or receipt against the referenced envelope.
- AFRI runtime adapter fallback remains available until snapshot-ledger parity is proven.

## Validation Commands

Run the tightest relevant commands first, then repair failures:

```bash
xcodegen generate
make xcode-build-for-testing
make xcode-focused-test BATCH=AFEP-003 TEST=AmbitionsTests
```

If a broad `AmbitionsTests` lane is too slow or blocked, run focused tests for the new AFEP runtime snapshot ledger, compatibility, redaction, and replay-hook models/services and clearly record the unrun broader lane as Yellow, not Green.

## Required Proof Artifacts

Create or update current artifacts for:

- Runtime ledger packet
- Replay validation report

Each artifact must include branch, commit if available, date/time, command names, pass/fail/skipped state, known Yellow items, rollback notes, and non-claims.

## Green / Yellow / Red Expectations

Green: receipts map to versioned envelopes and replay works from current local proof.

Yellow: ledger is source-present but adapter remains active with explicit parity limits, owner, follow-up gate, and no release overclaim.

Red: unversioned inputs, missing redaction, non-replayable receipts, hosted AI/backend dependency, canonical IA drift, or unproven release/accessibility/privacy/performance claims.

## Closeout Requirements

Closeout must include:

- Files changed
- Why the change was needed
- Truth files inspected
- Validation run and exact commands
- Validation not run and why
- Proof/claim boundaries
- Risks or Yellow items
- Rollback notes
- Linear issue status recommendation for AMB-397

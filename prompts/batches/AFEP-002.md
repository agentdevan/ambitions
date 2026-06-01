<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-002 — Lineage, Tombstones, And Recovery Graph

Linear issue: AMB-396
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
- AFEP-001 source, tests, and proof reports
- relevant persistence, domain, service, test, and proof files

Confirm AFEP-001 is locally Green before source edits. Do not modify, split, rename, or rewrite AFRI-000 through AFRI-040.

## Purpose

Preserve the history and recoverability of moved, skipped, deleted, or rewritten objects by adding deterministic lineage, tombstones, ancestry, recovery semantics, and export-safe lineage views to the post-AFRI local-first runtime.

## Product And Architecture Boundaries

- Preserve canonical IA: Today / Goals / Capture / Time / You.
- Preserve primary objects: Reality Meridian, Constellation Atlas, Atmosphere Composer, LifeShape Field, User System Profile.
- Preserve local-first Private Life Runtime as core architecture.
- Do not add cloud AI, hosted inference, analytics SDKs, backend accounts, custom server infrastructure, hosted CI, signing automation, or paid services.
- Do not claim release readiness, accessibility verification, performance verification, device proof, TestFlight readiness, App Store readiness, privacy/legal approval, or CI proof unless current evidence exists.
- Keep AFRI-compatible soft-delete and recovery semantics available as rollback until AFEP lineage behavior is proven.
- Runtime-affecting lineage and recovery records must preserve explicit `SourceRecord`, `Receipt`, and `ReplayTrace` wiring where the touched owner requires it.
- User-inspectable runtime history and recovery must remain visible through You / What Ambitions Knows inspection, including reset/delete/export boundaries where applicable.

## Implementation Scope

Implement the smallest source-backed lineage graph that satisfies AMB-396:

1. Add stable lineage IDs for object evolution.
2. Add tombstone records for skipped, deleted, rewritten, or finalized objects.
3. Add ancestry for moves and edits.
4. Define recovery semantics for recoverable and explicitly finalized states.
5. Define export-safe lineage views with privacy redaction boundaries.

Prefer existing owner seams and names over new broad architecture. Extend current persistence/domain/service/test owners where appropriate:

- `Native/Ambitions/Domain/`
- `Native/Ambitions/Persistence/`
- `Native/Ambitions/Services/`
- `Native/AmbitionsTests/`
- proof/report files under `build/reports/afep/AFEP-002/` or an equally scoped existing proof root

## Acceptance Gates

- Object evolution is interpretable from source-backed lineage records.
- Deleted, skipped, moved, and rewritten states are recoverable or explicitly finalized.
- Tombstones are deterministic and do not destroy proof history.
- Export-safe lineage views redact or omit privacy-sensitive fields by class.
- Recovery behavior is tested with at least one moved/edited object and one tombstoned object.
- SourceRecord, Receipt, ReplayTrace, and What Ambitions Knows inspection requirements are either implemented for touched runtime paths or recorded as Yellow with owner, no-claim boundary, and follow-up gate.
- AFRI-compatible soft-delete rollback behavior is retained.

## Validation Commands

Run the tightest relevant commands first, then repair failures:

```bash
xcodegen generate
make xcode-build-for-testing
make xcode-focused-test BATCH=AFEP-002 TEST=AmbitionsTests
```

If a broad `AmbitionsTests` lane is too slow or blocked, run focused tests for the new AFEP lineage/recovery models/services and clearly record the unrun broader lane as Yellow, not Green.

## Required Proof Artifacts

Create or update current artifacts for:

- Lineage graph packet
- Recovery simulation report

Each artifact must include branch, commit if available, date/time, command names, pass/fail/skipped state, known Yellow items, rollback notes, and non-claims.

## Green / Yellow / Red Expectations

Green: lineage and tombstones are source-backed, deterministic, export-safe, and recovery-tested with current proof artifacts.

Yellow: partial lineage coverage remains for documented unsupported object classes, with owner, follow-up gate, and no release overclaim.

Red: destructive deletion, unverifiable ancestry, privacy-unsafe export, hosted AI/backend dependency, canonical IA drift, or unproven release/accessibility/privacy/performance claims.

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
- Linear issue status recommendation for AMB-396

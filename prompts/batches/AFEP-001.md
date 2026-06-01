<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-001 — Operational, Proof, And Projection Store Split

Linear issue: AMB-395
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
- `docs/codex/AFRI_ACTIVE_AUTHORITY_MANIFEST.md`
- relevant persistence, domain, service, test, and proof files

Confirm AFRI is complete or owner-accepted enough before source edits. Do not modify, split, rename, or rewrite AFRI-000 through AFRI-040.

## Purpose

Separate live operational records, immutable proof records, and deterministic render projections so AFEP can deepen the post-AFRI local-first runtime without turning snapshots or blob fields into the ordinary read path.

## Product And Architecture Boundaries

- Preserve canonical IA: Today / Goals / Capture / Time / You.
- Preserve primary objects: Reality Meridian, Constellation Atlas, Atmosphere Composer, LifeShape Field, User System Profile.
- Preserve local-first Private Life Runtime as core architecture.
- Do not add cloud AI, hosted inference, analytics SDKs, backend accounts, custom server infrastructure, hosted CI, signing automation, or paid services.
- Do not claim release readiness, accessibility verification, performance verification, device proof, TestFlight readiness, App Store readiness, privacy/legal approval, or CI proof unless current evidence exists.
- Keep an AFRI-compatible operational read path behind a migration adapter until AFEP parity is proven.
- Runtime-affecting records must preserve explicit `SourceRecord`, `Receipt`, and `ReplayTrace` wiring where the touched owner requires it.
- User-inspectable runtime inputs and learning must remain visible through You / What Ambitions Knows inspection, including reset/delete boundaries where applicable.

## Implementation Scope

Implement the smallest source-backed split that satisfies AMB-395:

1. Define operational schemas for core product objects.
2. Define immutable proof/receipt records.
3. Define deterministic projections for Today, Goals, Time, and You.
4. Add projection invalidation/rebuild rules.
5. Add privacy classes.
6. Keep an AFRI-compatible migration path.

Prefer existing owner seams and names over new broad architecture. Extend current persistence/domain/service/test owners where appropriate:

- `Native/Ambitions/Persistence/`
- `Native/Ambitions/Domain/`
- `Native/Ambitions/Services/`
- `Native/AmbitionsTests/`
- proof/report files under `build/reports/afep/AFEP-001/` or an equally scoped existing proof root

## Acceptance Gates

- No major surface depends on blob-first reads for the new AFEP path.
- Projections are deterministic and replay-compatible.
- Proof records remain immutable by API/contract.
- Privacy class decisions are explicit for operational, proof, and projection records.
- SourceRecord, Receipt, ReplayTrace, and What Ambitions Knows inspection requirements are either implemented for touched runtime paths or recorded as Yellow with owner, no-claim boundary, and follow-up gate.
- AFRI-compatible rollback/migration adapter is retained.

## Validation Commands

Run the tightest relevant commands first, then repair failures:

```bash
xcodegen generate
make xcode-build-for-testing
make xcode-focused-test BATCH=AFEP-001 TEST=AmbitionsTests
```

If a broad `AmbitionsTests` lane is too slow or blocked, run focused tests for the new AFEP models/services and clearly record the unrun broader lane as Yellow, not Green.

## Required Proof Artifacts

Create or update current artifacts for:

- Query-budget report
- Projection diff packet
- Replay compatibility matrix

Each artifact must include branch, commit if available, date/time, command names, pass/fail/skipped state, known Yellow items, rollback notes, and non-claims.

## Green / Yellow / Red Expectations

Green: the split is source-backed, deterministic, replay-compatible, proof immutability is enforced by focused tests, and the named proof packets exist with current evidence.

Yellow: adapter remains primary or broad validation is incomplete, with documented parity gaps, owner, follow-up gate, and no release overclaim.

Red: proof mutability, blob-first dependency remains in the new AFEP path, unsafe migration path, privacy boundary regression, hosted AI/backend dependency, canonical IA drift, or unproven release/accessibility/privacy/performance claims.

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
- Linear issue status recommendation for AMB-395

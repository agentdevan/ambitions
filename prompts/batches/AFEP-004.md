<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-004 - Query Budgets and Privacy Classes

Linear issue: AMB-398
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
- `prompts/batches/AFEP-003.md`
- AFEP-001, AFEP-002, and AFEP-003 source, tests, commits, and proof reports
- relevant persistence, privacy, export, query, signpost, performance, release-proof, and surface projection files

Confirm AFEP-001 through AFEP-003 are locally Green before source edits. Do not modify, split, rename, or rewrite AFRI-000 through AFRI-040.

## Purpose

Bind storage design to UX performance and privacy claims by making query ceilings, field privacy classes, indexing policy, export behavior, and measurement boundaries explicit in source-backed contracts and proof artifacts.

## Product And Architecture Boundaries

- Preserve canonical IA: Today / Goals / Capture / Time / You.
- Preserve primary objects: Reality Meridian, Constellation Atlas, Atmosphere Composer, LifeShape Field, User System Profile.
- Preserve local-first Private Life Runtime as core architecture.
- Do not add cloud AI, hosted inference, analytics SDKs, backend accounts, custom server infrastructure, hosted CI, signing automation, or paid services.
- Do not claim release readiness, accessibility verification, performance verification, device proof, TestFlight readiness, App Store readiness, privacy/legal approval, or CI proof unless current evidence exists.
- Query budgets are contract ceilings and wrapper/local proof only unless backed by current measured device or Instruments evidence.
- Conservative privacy defaults remain active until all field classes and export policies are source-backed and validated.
- Do not add private metadata to indexes or external projections unless export safety and privacy class are explicit.
- Any touched budget, privacy, export, proof, or replay path must preserve explicit `SourceRecord`, `Receipt`, and `ReplayTrace` boundaries and must not create a parallel owner for those concepts.
- User-inspectable privacy, storage, and export behavior must remain visible through You / What Ambitions knows inspection where the touched owner exposes it.

## Implementation Scope

Implement the smallest source-backed query budget and privacy-class layer that satisfies AMB-398:

1. Define per-surface read/query budgets for major surfaces and persistence-backed projections.
2. Add signpost or signpost-plan contracts without claiming measured performance unless evidence exists.
3. Add privacy labels/classes for sensitive fields touched by AFEP persistence/runtime graph work.
4. Add indexing and export rules that prevent private metadata leakage.
5. Perform a storage-class review and record conservative defaults.

Prefer existing owner seams and names over new broad architecture. Extend current domain, persistence, support, test, and proof owners where appropriate:

- `Native/Ambitions/Domain/`
- `Native/Ambitions/Persistence/`
- `Native/Ambitions/Support/`
- `Native/Ambitions/Features/You/` only if needed for an existing inspection seam
- `Native/AmbitionsTests/`
- proof/report files under `build/reports/afep/AFEP-004/` or an equally scoped existing proof root

## Acceptance Gates

- Major surfaces have explicit query/read ceilings.
- Sensitive fields have storage class, privacy class, indexing policy, and export policy.
- Signpost/measurement contracts distinguish planned, locally measured, device measured, and unverified states.
- Indexing rules do not expose private metadata.
- Export rules are conservative by default and test-covered where source changes are made.
- Budget and privacy claims are backed by current local evidence or explicitly marked Yellow.

## Validation Commands

Run the tightest relevant commands first, then repair failures:

```bash
xcodegen generate
make xcode-build-for-testing
make xcode-focused-test BATCH=AFEP-004 TEST=AmbitionsTests
```

If a broad `AmbitionsTests` lane is too slow or blocked, run focused tests for the new AFEP query-budget, privacy-class, indexing, export-policy, and storage-class models/services and clearly record the unrun broader lane as Yellow, not Green.

## Required Proof Artifacts

Create or update current artifacts for:

- Budget report
- Privacy matrix

Each artifact must include branch, commit if available, date/time, command names, pass/fail/skipped state, known Yellow items, rollback notes, and non-claims.

## Green / Yellow / Red Expectations

Green: budgets and privacy classes are source-backed, tested, measured where claimed, and documented with current proof.

Yellow: conservative defaults remain active with bounded measurement gaps, owner, follow-up gate, and no release/performance/privacy overclaim.

Red: sensitive field lacks policy, budget claim lacks logs, indexing leaks private metadata, hosted AI/backend dependency appears, canonical IA drifts, or release/accessibility/privacy/performance claims exceed evidence.

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
- Linear issue status recommendation for AMB-398

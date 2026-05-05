# AQOS Source Truth And Overlay Insertion Report
<!-- markdownlint-disable MD013 -->

Result: PASS WITH ACCEPTED YELLOW
Date: 2026-05-05
Scope: Docs / Codex OS / quality overlay only

## Task

Implement AQOS — Autonomous Quality Operating System — into the repo so Codex can operate like a FAANG-level cross-functional implementation department with evidence-gated quality.

The user approved AQOS after a rendered visual quality gap showed that structurally correct implementation can still produce below-bar product experience.

## Live Repo State Used

Before writing AQOS files, live repo state was fetched:

- `.codex/reports/current-run-state.md` from `main` with SHA `9c9c26ef201b6527bd8ee9986050d10577cb6aad` at inspection.
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER.md` from `main` with SHA `ef58d4d8ef5fab97d7ebf61bd573091baf258b9b` at inspection.

The active Codex run was still moving, so AQOS was added as source truth and global overlay rather than direct active run-state mutation.

## Files Created

- `docs/codex/quality/AQOS_AUTONOMOUS_QUALITY_OPERATING_SYSTEM.md`
- `docs/codex/quality/AQOS01_AQOS30_AUTONOMOUS_QUALITY_TRAIN.md`
- `docs/codex/quality/AQOS_REQUIRED_EVIDENCE_MATRIX.md`
- `docs/codex/quality/AQOS_BATCH_IMPACT_CLASSIFIER.md`
- `docs/codex/quality/AQOS_REPAIR_BATCH_GENERATOR_PROTOCOL.md`
- `docs/codex/quality/AQOS_EVIDENCE_MATURITY_LEDGER.md`
- `docs/codex/quality/AQOS_DOMAIN_QUALITY_GATES.md`
- `docs/codex/quality/AQOS_GOLDEN_SCENARIO_AND_STATE_COVERAGE.md`
- `docs/codex/quality/AQOS_AUTONOMOUS_QUALITY_COUNCIL.md`
- `docs/codex/GLOBAL_AUTONOMOUS_QUALITY_OVERLAY.md`
- `docs/codex/batches/AQOS_AUTONOMOUS_QUALITY_CONTINUATION_PROMPT.md`
- `.codex/skills/autonomous-quality-operating-system-reviewer.md`
- `docs/audits/aqos-source-truth-and-overlay-insertion-report.md`

## What AQOS Adds

### No Matching Evidence, No Green

A batch cannot close Green unless it produces the evidence required for the domain it changed.

### Green Taxonomy

Green is now specific:

- Structural Green
- Behavioral Green
- Rendered Visual Green
- Accessibility Green
- Privacy Green
- Data Integrity Green
- Performance Green
- Architecture Green
- Copy Green
- Platform Green
- Release Green
- Handoff Green

### Batch Impact Classifier

Every batch must classify touched domains and inherit required proof gates.

### Required Evidence Matrix

Maps each touched domain to mandatory evidence.

### Domain Gates

Adds quality gates for:

- AXQ Accessibility Execution Quality
- PVQ Privacy Exposure Quality
- DIQ Data Integrity Quality
- PERQ Performance / Battery Quality
- ARQ Architecture / Repo Quality
- UXW User-Facing Copy Quality
- RIQ Recommendation / Intelligence Quality
- ESQ External Surface Quality
- MQ Monetization Quality
- RQ Release / App Store / Claim Truth Quality
- HQ Handoff Quality

### Golden Scenario And State Coverage

Requires realistic scenario coverage, including overloaded day, baby/family, forgotten promise, private commitment, stale source, career pivot, weekly sweep, recovery, and Found Life context.

### Autonomous Quality Council

Major batches must be reviewed by synthetic cross-functional roles:

- Founder Vision Guardian
- Chief Product Reviewer
- Apple Design Award Visual Reviewer
- Staff iOS Architect
- Senior SwiftUI Composition Reviewer
- Accessibility Lead
- Privacy / Security Reviewer
- Performance / Battery Reviewer
- QA / Test Lead
- App Store / Claim Truth Reviewer
- Legal Boundary Reviewer
- FAANG Handoff Auditor

### Repair Batch Generator

Recoverable Red creates narrow repair batches instead of broad improvisation or vague Yellow.

### Evidence Maturity Ledger

Tracks major objects by proof maturity rather than only batch completion.

## Why Overlay Instead Of Direct Run-State Mutation

The active global train is moving. Editing run-state directly from a remote connector could overwrite or conflict with local in-progress work. AQOS therefore uses:

- stable source-truth files;
- a global overlay;
- a continuation prompt;
- a reviewer skill;
- no production Swift edits.

The next Codex pull should read `GLOBAL_AUTONOMOUS_QUALITY_OVERLAY.md` and adopt AQOS at the earliest safe batch boundary.

## No-Claim Boundaries

This insertion does not claim:

- AQOS has run;
- visual issues are fixed;
- accessibility is publicly proven;
- privacy/legal/security compliance exists;
- app is release/App Store/TestFlight ready;
- physical-device proof exists;
- AOS/LDI runtime is complete;
- final handoff is ready.

It installs the operating system layer required to prove those things later.

## Validation

This update was performed through the GitHub connector. Local shell validation was not available in this session. The following were not run here:

- `git status --short`
- `git diff --check`
- `scripts/run-doc-qa.sh`
- `scripts/batch-train-gate-check.sh`

The update remained docs/skill/overlay-only and did not edit production Swift, route/raw values, persistence/schema, workflows, signing, entitlements, CI, release, sync/cloud, monetization, AI runtime, or LDI runtime files.

## Accepted Yellow

- Active local Codex work may not read AQOS until its next pull.
- Run-state/context files were not rewritten here to avoid colliding with active work.
- No AQOS scripts were executed in this connector session.
- AQOS source truth is installed, but AQOS adoption/integration batch still must run.

## Next Expected Action

When Codex reaches the next safe batch boundary:

1. Finish active batch safely.
2. Pull latest.
3. Read `docs/codex/GLOBAL_AUTONOMOUS_QUALITY_OVERLAY.md`.
4. Run `docs/codex/batches/AQOS_AUTONOMOUS_QUALITY_CONTINUATION_PROMPT.md` or equivalent AQOS adoption batch.
5. Integrate AQOS into the global orchestrator, report template, registry/context, and scripts.
6. Resume global full-stack order only after no AQOS Hard Red remains.
